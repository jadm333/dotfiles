// moni - toggle one external macOS monitor/display from the desktop layout.
//
// CGSConfigureDisplayEnabled is private CoreGraphics SPI. Apple can remove or
// change it without notice. Changes use login-session scope so logout remains
// the recovery path if the private API stops cooperating.

#include <ColorSync/ColorSync.h>
#include <CoreGraphics/CoreGraphics.h>
#include <bsm/audit.h>
#include <ctype.h>
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define MAX_DISPLAYS 32

typedef CGError (*ConfigureDisplayEnabledFn)(CGDisplayConfigRef,
                                             CGDirectDisplayID, bool);

typedef struct {
  CGDirectDisplayID ids[MAX_DISPLAYS];
  uint32_t count;
} DisplayList;

typedef enum {
  CONFIGURE_REJECTED,
  CONFIGURE_COMMITTED,
  CONFIGURE_UNCERTAIN,
} ConfigureOutcome;

static const char *const PRIVATE_SYMBOL = "CGSConfigureDisplayEnabled";
static const unsigned int POLL_INTERVAL_MS = 100;
static const unsigned int RECONFIGURE_TIMEOUT_MS = 3000;

static void usage(FILE *stream) {
  fprintf(stream, "usage: monictl list\n"
                  "       monictl check\n"
                  "       monictl status display-uuid\n"
                  "       monictl toggle display-uuid\n"
                  "       monictl recover display-uuid display-id\n"
                  "\n"
                  "Display changes last for the current login session only.\n");
}

static ConfigureDisplayEnabledFn load_private_api(void) {
  dlerror();
  void *address = dlsym(RTLD_DEFAULT, PRIVATE_SYMBOL);
  const char *error = dlerror();
  if (error != NULL || address == NULL) {
    fprintf(stderr,
            "monictl: private CoreGraphics symbol %s is unavailable; "
            "this macOS release is not supported\n",
            PRIVATE_SYMBOL);
    return NULL;
  }

  union {
    void *object;
    ConfigureDisplayEnabledFn function;
  } symbol = {.object = address};
  return symbol.function;
}

static bool get_online_displays(DisplayList *list, bool quiet) {
  list->count = 0;
  CGError error = CGGetOnlineDisplayList(MAX_DISPLAYS, list->ids, &list->count);
  if (error == kCGErrorSuccess) {
    return true;
  }
  if (!quiet) {
    fprintf(stderr,
            "monictl: could not list online displays "
            "(CoreGraphics error %d)\n",
            error);
  }
  return false;
}

static bool display_uuid(CGDirectDisplayID id, char *buffer,
                         size_t buffer_size) {
  CFUUIDRef uuid = CGDisplayCreateUUIDFromDisplayID(id);
  if (uuid == NULL) {
    return false;
  }
  CFStringRef string = CFUUIDCreateString(kCFAllocatorDefault, uuid);
  CFRelease(uuid);
  if (string == NULL) {
    return false;
  }
  Boolean converted = CFStringGetCString(string, buffer, (CFIndex)buffer_size,
                                         kCFStringEncodingUTF8);
  CFRelease(string);
  return converted;
}

static bool normalize_uuid(const char *input, char *buffer,
                           size_t buffer_size) {
  if (strlen(input) != 36) {
    return false;
  }
  bool has_nonzero_digit = false;
  for (size_t index = 0; index < 36; ++index) {
    bool separator = index == 8 || index == 13 || index == 18 || index == 23;
    if (separator) {
      if (input[index] != '-') {
        return false;
      }
    } else {
      if (!isxdigit((unsigned char)input[index])) {
        return false;
      }
      has_nonzero_digit = has_nonzero_digit || input[index] != '0';
    }
  }
  if (!has_nonzero_digit) {
    return false;
  }

  CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, input,
                                                 kCFStringEncodingUTF8);
  if (string == NULL) {
    return false;
  }
  CFUUIDRef uuid = CFUUIDCreateFromString(kCFAllocatorDefault, string);
  CFRelease(string);
  if (uuid == NULL) {
    return false;
  }
  CFStringRef normalized = CFUUIDCreateString(kCFAllocatorDefault, uuid);
  CFRelease(uuid);
  if (normalized == NULL) {
    return false;
  }
  Boolean converted = CFStringGetCString(
      normalized, buffer, (CFIndex)buffer_size, kCFStringEncodingUTF8);
  CFRelease(normalized);
  return converted;
}

static bool parse_display_id(const char *input, CGDirectDisplayID *display_id) {
  errno = 0;
  char *end = NULL;
  unsigned long value = strtoul(input, &end, 10);
  if (errno != 0 || end == input || *end != '\0' || value == 0 ||
      value > UINT32_MAX) {
    return false;
  }
  *display_id = (CGDirectDisplayID)value;
  return true;
}

static bool display_enabled(CGDirectDisplayID id) {
  return CGDisplayIsActive(id) || CGDisplayIsInMirrorSet(id);
}

static bool list_contains_id(const DisplayList *list, CGDirectDisplayID id) {
  for (uint32_t index = 0; index < list->count; ++index) {
    if (list->ids[index] == id) {
      return true;
    }
  }
  return false;
}

static bool find_uuid(const DisplayList *list, const char *uuid,
                      CGDirectDisplayID *display_id) {
  for (uint32_t index = 0; index < list->count; ++index) {
    char candidate[64];
    if (display_uuid(list->ids[index], candidate, sizeof(candidate)) &&
        strcasecmp(candidate, uuid) == 0) {
      *display_id = list->ids[index];
      return true;
    }
  }
  return false;
}

static int print_displays(const DisplayList *list) {
  if (list->count == 0) {
    fprintf(stderr,
            "monictl: no online displays are visible in this login session\n");
    return 1;
  }
  for (uint32_t index = 0; index < list->count; ++index) {
    CGDirectDisplayID id = list->ids[index];
    char uuid[64];
    if (!display_uuid(id, uuid, sizeof(uuid))) {
      fprintf(stderr, "monictl: could not obtain UUID for display %u\n", id);
      return 1;
    }
    printf("%s id:%u enabled:%d active:%d asleep:%d main:%d builtin:%d "
           "width:%zu height:%zu vendor:0x%04x model:0x%08x "
           "serial:0x%08x\n",
           uuid, id, display_enabled(id) ? 1 : 0, CGDisplayIsActive(id) ? 1 : 0,
           CGDisplayIsAsleep(id) ? 1 : 0, CGDisplayIsMain(id) ? 1 : 0,
           CGDisplayIsBuiltin(id) ? 1 : 0, CGDisplayPixelsWide(id),
           CGDisplayPixelsHigh(id), CGDisplayVendorNumber(id),
           CGDisplayModelNumber(id), CGDisplaySerialNumber(id));
  }
  return 0;
}

static bool has_other_active_display(const DisplayList *list,
                                     CGDirectDisplayID target) {
  for (uint32_t index = 0; index < list->count; ++index) {
    if (list->ids[index] != target && CGDisplayIsActive(list->ids[index])) {
      return true;
    }
  }
  return false;
}

static bool runtime_directory(char *buffer, size_t buffer_size, bool create,
                              bool quiet) {
  char user_temp[PATH_MAX];
  size_t required =
      confstr(_CS_DARWIN_USER_TEMP_DIR, user_temp, sizeof(user_temp));
  if (required == 0 || required > sizeof(user_temp)) {
    if (!quiet) {
      fprintf(
          stderr,
          "monictl: could not determine the per-user temporary directory\n");
    }
    return false;
  }
  size_t length = strlen(user_temp);
  const char *separator = length > 0 && user_temp[length - 1] == '/' ? "" : "/";
  int written =
      snprintf(buffer, buffer_size, "%s%smonictl", user_temp, separator);
  if (written < 0 || (size_t)written >= buffer_size) {
    if (!quiet) {
      fprintf(stderr, "monictl: runtime directory path is too long\n");
    }
    return false;
  }
  if (create && mkdir(buffer, S_IRWXU) == -1 && errno != EEXIST) {
    if (!quiet) {
      fprintf(stderr, "monictl: could not create runtime directory: %s\n",
              strerror(errno));
    }
    return false;
  }

  struct stat metadata;
  if (lstat(buffer, &metadata) == -1 || !S_ISDIR(metadata.st_mode) ||
      metadata.st_uid != geteuid() || (metadata.st_mode & 0777) != S_IRWXU) {
    if (!quiet) {
      fprintf(stderr, "monictl: runtime directory is missing or has unsafe "
                      "permissions\n");
    }
    return false;
  }
  return true;
}

static bool cache_path(const char *uuid, char *buffer, size_t buffer_size,
                       bool create_directory, bool quiet) {
  char directory[PATH_MAX];
  if (!runtime_directory(directory, sizeof(directory), create_directory,
                         quiet)) {
    return false;
  }
  int written = snprintf(buffer, buffer_size, "%s/%s.id", directory, uuid);
  return written >= 0 && (size_t)written < buffer_size;
}

static bool current_audit_session(au_asid_t *session_id) {
  struct auditinfo_addr information;
  if (getaudit_addr(&information, (int)sizeof(information)) == -1) {
    return false;
  }
  if (information.ai_asid <= 0) {
    return false;
  }
  *session_id = information.ai_asid;
  return true;
}

static int acquire_operation_lock(void) {
  char directory[PATH_MAX];
  if (!runtime_directory(directory, sizeof(directory), true, false)) {
    return -1;
  }
  char path[PATH_MAX];
  int written = snprintf(path, sizeof(path), "%s/.lock", directory);
  if (written < 0 || (size_t)written >= sizeof(path)) {
    fprintf(stderr, "monictl: lock path is too long\n");
    return -1;
  }

  int descriptor =
      open(path, O_RDWR | O_CREAT | O_CLOEXEC | O_NOFOLLOW, S_IRUSR | S_IWUSR);
  if (descriptor == -1) {
    fprintf(stderr, "monictl: could not open operation lock: %s\n",
            strerror(errno));
    return -1;
  }
  struct stat metadata;
  if (fstat(descriptor, &metadata) == -1 || !S_ISREG(metadata.st_mode) ||
      metadata.st_uid != geteuid() ||
      (metadata.st_mode & 0777) != (S_IRUSR | S_IWUSR)) {
    fprintf(stderr, "monictl: operation lock has unsafe permissions\n");
    close(descriptor);
    return -1;
  }
  while (flock(descriptor, LOCK_EX) == -1) {
    if (errno == EINTR) {
      continue;
    }
    fprintf(stderr, "monictl: could not acquire operation lock: %s\n",
            strerror(errno));
    close(descriptor);
    return -1;
  }
  return descriptor;
}

static void delete_cached_id(const char *uuid) {
  char path[PATH_MAX];
  if (cache_path(uuid, path, sizeof(path), false, true)) {
    (void)unlink(path);
  }
}

static bool read_cached_id(const char *uuid, CGDirectDisplayID *display_id) {
  char path[PATH_MAX];
  if (!cache_path(uuid, path, sizeof(path), false, true)) {
    return false;
  }
  int descriptor = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
  if (descriptor == -1) {
    return false;
  }
  struct stat metadata;
  if (fstat(descriptor, &metadata) == -1 || !S_ISREG(metadata.st_mode) ||
      metadata.st_uid != geteuid() ||
      (metadata.st_mode & 0777) != (S_IRUSR | S_IWUSR) ||
      metadata.st_size <= 0 || metadata.st_size >= 96) {
    close(descriptor);
    return false;
  }

  char contents[96];
  size_t expected = (size_t)metadata.st_size;
  size_t total = 0;
  while (total < expected) {
    ssize_t count = read(descriptor, contents + total, expected - total);
    if (count == -1 && errno == EINTR) {
      continue;
    }
    if (count <= 0) {
      close(descriptor);
      return false;
    }
    total += (size_t)count;
  }
  char extra;
  ssize_t trailing;
  do {
    trailing = read(descriptor, &extra, 1);
  } while (trailing == -1 && errno == EINTR);
  close(descriptor);
  if (trailing != 0) {
    return false;
  }
  contents[total] = '\0';

  int cached_session = 0;
  unsigned int cached_id = 0;
  int consumed = 0;
  int fields = sscanf(contents, "version=1\nsession=%d\nid=%u\n%n",
                      &cached_session, &cached_id, &consumed);
  au_asid_t current_session;
  if (fields != 2 || consumed != (int)total || cached_id == 0 ||
      !current_audit_session(&current_session) ||
      cached_session != (int)current_session) {
    return false;
  }
  *display_id = (CGDirectDisplayID)cached_id;
  return true;
}

static bool write_all(int descriptor, const char *buffer, size_t length) {
  size_t total = 0;
  while (total < length) {
    ssize_t count = write(descriptor, buffer + total, length - total);
    if (count == -1 && errno == EINTR) {
      continue;
    }
    if (count <= 0) {
      return false;
    }
    total += (size_t)count;
  }
  return true;
}

static bool write_cached_id(const char *uuid, CGDirectDisplayID display_id) {
  au_asid_t session_id;
  if (!current_audit_session(&session_id)) {
    fprintf(stderr, "monictl: could not determine the current login session\n");
    return false;
  }

  char path[PATH_MAX];
  if (!cache_path(uuid, path, sizeof(path), true, false)) {
    return false;
  }
  char temporary[PATH_MAX];
  int length = snprintf(temporary, sizeof(temporary), "%s.XXXXXX", path);
  if (length < 0 || (size_t)length >= sizeof(temporary)) {
    fprintf(stderr, "monictl: temporary cache path is too long\n");
    return false;
  }
  int descriptor = mkstemp(temporary);
  if (descriptor == -1) {
    fprintf(stderr, "monictl: could not create display ID cache: %s\n",
            strerror(errno));
    return false;
  }

  char contents[96];
  length =
      snprintf(contents, sizeof(contents), "version=1\nsession=%d\nid=%u\n",
               (int)session_id, display_id);
  bool success = length > 0 && (size_t)length < sizeof(contents) &&
                 fchmod(descriptor, S_IRUSR | S_IWUSR) == 0 &&
                 write_all(descriptor, contents, (size_t)length);
  int saved_errno = success ? 0 : (errno != 0 ? errno : EIO);
  if (close(descriptor) == -1 && success) {
    success = false;
    saved_errno = errno;
  }
  if (!success) {
    unlink(temporary);
    fprintf(stderr, "monictl: could not write display ID cache: %s\n",
            strerror(saved_errno));
    return false;
  }
  if (rename(temporary, path) == -1) {
    saved_errno = errno;
    unlink(temporary);
    fprintf(stderr, "monictl: could not install display ID cache: %s\n",
            strerror(saved_errno));
    return false;
  }
  return true;
}

static ConfigureOutcome configure_display(ConfigureDisplayEnabledFn configure,
                                          CGDirectDisplayID target, bool enable,
                                          bool quiet) {
  CGDisplayConfigRef configuration = NULL;
  CGError error = CGBeginDisplayConfiguration(&configuration);
  if (error != kCGErrorSuccess || configuration == NULL) {
    if (!quiet) {
      fprintf(stderr,
              "monictl: could not begin display configuration "
              "(CoreGraphics error %d)\n",
              error);
    }
    return CONFIGURE_REJECTED;
  }
  error = configure(configuration, target, enable);
  if (error != kCGErrorSuccess) {
    CGCancelDisplayConfiguration(configuration);
    if (!quiet) {
      fprintf(stderr, "monictl: %s failed (CoreGraphics error %d)\n",
              PRIVATE_SYMBOL, error);
    }
    return CONFIGURE_REJECTED;
  }
  error = CGCompleteDisplayConfiguration(configuration, kCGConfigureForSession);
  if (error != kCGErrorSuccess) {
    if (!quiet) {
      fprintf(stderr,
              "monictl: could not complete display configuration "
              "(CoreGraphics error %d)\n",
              error);
    }
    return CONFIGURE_UNCERTAIN;
  }
  return CONFIGURE_COMMITTED;
}

static void poll_pause(void) {
  struct timespec duration = {
      .tv_sec = 0,
      .tv_nsec = (long)POLL_INTERVAL_MS * 1000L * 1000L,
  };
  while (nanosleep(&duration, &duration) == -1 && errno == EINTR) {
  }
}

static bool wait_for_uuid_state(const char *uuid, bool enable,
                                CGDirectDisplayID *display_id) {
  for (unsigned int elapsed = 0; elapsed <= RECONFIGURE_TIMEOUT_MS;
       elapsed += POLL_INTERVAL_MS) {
    DisplayList displays;
    if (get_online_displays(&displays, true)) {
      CGDirectDisplayID found = kCGNullDirectDisplay;
      bool online = find_uuid(&displays, uuid, &found);
      bool matches = enable ? online && display_enabled(found)
                            : !online || !display_enabled(found);
      if (matches) {
        if (display_id != NULL) {
          *display_id = found;
        }
        return true;
      }
    }
    if (elapsed < RECONFIGURE_TIMEOUT_MS) {
      poll_pause();
    }
  }
  return false;
}

static bool restore_probe_baseline(ConfigureDisplayEnabledFn configure,
                                   const DisplayList *baseline,
                                   CGDirectDisplayID candidate,
                                   CGDirectDisplayID keep) {
  for (unsigned int elapsed = 0; elapsed <= RECONFIGURE_TIMEOUT_MS;
       elapsed += POLL_INTERVAL_MS) {
    DisplayList current;
    if (get_online_displays(&current, true)) {
      bool baseline_present = true;
      for (uint32_t index = 0; index < baseline->count; ++index) {
        if (!list_contains_id(&current, baseline->ids[index])) {
          baseline_present = false;
          break;
        }
      }
      if (!baseline_present) {
        if (candidate != keep) {
          (void)configure_display(configure, candidate, false, true);
        }
        return false;
      }

      CGDirectDisplayID new_enabled = kCGNullDirectDisplay;
      uint32_t new_enabled_count = 0;
      for (uint32_t index = 0; index < current.count; ++index) {
        CGDirectDisplayID id = current.ids[index];
        if (id != keep && !list_contains_id(baseline, id) &&
            display_enabled(id)) {
          new_enabled = id;
          ++new_enabled_count;
        }
      }

      bool candidate_enabled = candidate != keep &&
                               list_contains_id(&current, candidate) &&
                               display_enabled(candidate);
      if (new_enabled_count == 0 && !candidate_enabled) {
        return true;
      }
      if (new_enabled_count > 1) {
        if (candidate != keep) {
          (void)configure_display(configure, candidate, false, true);
        }
        return false;
      }

      if (new_enabled_count == 1) {
        (void)configure_display(configure, new_enabled, false, true);
      }
      if (candidate != keep &&
          (new_enabled_count == 0 || candidate != new_enabled)) {
        (void)configure_display(configure, candidate, false, true);
      }
    } else if (candidate != keep) {
      // Do not claim success from a candidate-only check. Retry until a full
      // topology snapshot proves the baseline has been restored.
      (void)configure_display(configure, candidate, false, true);
    }

    if (elapsed < RECONFIGURE_TIMEOUT_MS) {
      poll_pause();
    }
  }
  return false;
}

static int enable_candidate(ConfigureDisplayEnabledFn configure,
                            const char *uuid, CGDirectDisplayID candidate) {
  DisplayList baseline;
  if (!get_online_displays(&baseline, false)) {
    return 1;
  }
  CGDirectDisplayID existing = kCGNullDirectDisplay;
  if (find_uuid(&baseline, uuid, &existing) && display_enabled(existing)) {
    delete_cached_id(uuid);
    printf("monictl: external display is already enabled\n");
    return 0;
  }
  if (list_contains_id(&baseline, candidate)) {
    fprintf(stderr,
            "monictl: display ID %u already belongs to an online display; "
            "refusing to probe it\n",
            candidate);
    return 1;
  }

  ConfigureOutcome outcome =
      configure_display(configure, candidate, true, true);
  if (outcome == CONFIGURE_REJECTED) {
    fprintf(stderr, "monictl: macOS rejected display ID %u\n", candidate);
    return 1;
  }

  CGDirectDisplayID enabled_id = kCGNullDirectDisplay;
  if (wait_for_uuid_state(uuid, true, &enabled_id) &&
      !CGDisplayIsBuiltin(enabled_id)) {
    bool restored =
        restore_probe_baseline(configure, &baseline, candidate, enabled_id);
    delete_cached_id(uuid);
    if (!restored || !wait_for_uuid_state(uuid, true, &enabled_id)) {
      fprintf(stderr,
              "monictl: target display returned, but another topology change "
              "could not be rolled back cleanly\n");
      return 1;
    }
    printf("monictl: external display enabled for this login session\n");
    return 0;
  }

  bool restored = restore_probe_baseline(configure, &baseline, candidate,
                                         kCGNullDirectDisplay);
  delete_cached_id(uuid);
  if (!restored) {
    fprintf(stderr,
            "monictl: display ID %u was not the target and its prior state "
            "could not be restored\n",
            candidate);
  } else {
    fprintf(stderr,
            "monictl: display ID %u did not restore display %s; log out or "
            "reconnect it once\n",
            candidate, uuid);
  }
  return 1;
}

static int enable_online_display(ConfigureDisplayEnabledFn configure,
                                 CGDirectDisplayID target, const char *uuid) {
  if (CGDisplayIsBuiltin(target)) {
    fprintf(stderr, "monictl: refusing to operate on a built-in display\n");
    return 1;
  }
  ConfigureOutcome outcome = configure_display(configure, target, true, false);
  CGDirectDisplayID enabled_id = kCGNullDirectDisplay;
  if (outcome != CONFIGURE_REJECTED &&
      wait_for_uuid_state(uuid, true, &enabled_id) &&
      !CGDisplayIsBuiltin(enabled_id)) {
    delete_cached_id(uuid);
    printf("monictl: external display enabled for this login session\n");
    return 0;
  }
  fprintf(stderr,
          "monictl: macOS did not report the target display as enabled\n");
  return 1;
}

static int disable_display(ConfigureDisplayEnabledFn configure,
                           const DisplayList *online, CGDirectDisplayID target,
                           const char *uuid) {
  if (CGDisplayIsBuiltin(target)) {
    fprintf(stderr, "monictl: refusing to disable a built-in display\n");
    return 1;
  }
  if (!has_other_active_display(online, target)) {
    fprintf(stderr, "monictl: refusing to disable the last active display\n");
    return 1;
  }
  if (!write_cached_id(uuid, target)) {
    fprintf(stderr,
            "monictl: refusing to disable the display without caching its "
            "session ID\n");
    return 1;
  }
  if (CGDisplayIsMain(target)) {
    fprintf(stderr, "monictl: disabling the main display; macOS should promote "
                    "another display\n");
  }

  ConfigureOutcome outcome = configure_display(configure, target, false, false);
  if (outcome == CONFIGURE_REJECTED) {
    delete_cached_id(uuid);
    fprintf(stderr, "monictl: macOS rejected the display-disable request\n");
    return 1;
  }
  if (wait_for_uuid_state(uuid, false, NULL)) {
    printf("monictl: external display disabled for this login session\n");
    return 0;
  }

  DisplayList current;
  CGDirectDisplayID found = kCGNullDirectDisplay;
  if (get_online_displays(&current, true) &&
      find_uuid(&current, uuid, &found) && display_enabled(found)) {
    delete_cached_id(uuid);
  }
  fprintf(stderr,
          "monictl: macOS did not report the target display as disabled\n");
  return 1;
}

int main(int argc, char **argv) {
  if (argc == 2 &&
      (strcmp(argv[1], "help") == 0 || strcmp(argv[1], "--help") == 0 ||
       strcmp(argv[1], "-h") == 0)) {
    usage(stdout);
    return 0;
  }
  if (argc == 2 && strcmp(argv[1], "check") == 0) {
    au_asid_t session_id;
    if (load_private_api() == NULL) {
      return 1;
    }
    if (!current_audit_session(&session_id)) {
      fprintf(stderr, "monictl: a graphical login audit session is required\n");
      return 1;
    }
    printf("monictl: private CoreGraphics API is available\n");
    return 0;
  }

  bool is_list = argc == 2 && strcmp(argv[1], "list") == 0;
  bool is_status = argc == 3 && strcmp(argv[1], "status") == 0;
  bool is_toggle = argc == 3 && strcmp(argv[1], "toggle") == 0;
  bool is_recover = argc == 4 && strcmp(argv[1], "recover") == 0;
  if (!is_list && !is_status && !is_toggle && !is_recover) {
    usage(stderr);
    return 2;
  }

  char uuid[64] = {0};
  if (!is_list && !normalize_uuid(argv[2], uuid, sizeof(uuid))) {
    fprintf(stderr, "monictl: invalid display UUID %s\n", argv[2]);
    return 2;
  }
  CGDirectDisplayID recovery_id = kCGNullDirectDisplay;
  if (is_recover && !parse_display_id(argv[3], &recovery_id)) {
    fprintf(stderr, "monictl: invalid recovery display ID %s\n", argv[3]);
    return 2;
  }

  int operation_lock = -1;
  if (is_toggle || is_recover) {
    operation_lock = acquire_operation_lock();
    if (operation_lock == -1) {
      return 1;
    }
  }

  DisplayList displays;
  if (!get_online_displays(&displays, false)) {
    if (operation_lock != -1) {
      close(operation_lock);
    }
    return 1;
  }
  if (is_list) {
    return print_displays(&displays);
  }

  CGDirectDisplayID target = kCGNullDirectDisplay;
  bool target_online = find_uuid(&displays, uuid, &target);
  if (is_status) {
    const char *state;
    if (target_online && display_enabled(target)) {
      state = "enabled";
    } else if (target_online) {
      state = "disabled";
    } else {
      CGDirectDisplayID cached = kCGNullDirectDisplay;
      state = read_cached_id(uuid, &cached) ? "disabled" : "offline";
    }
    printf("%s %s\n", uuid, state);
    return 0;
  }

  ConfigureDisplayEnabledFn configure = load_private_api();
  if (configure == NULL) {
    close(operation_lock);
    return 1;
  }

  int result;
  if (is_recover) {
    if (target_online && display_enabled(target)) {
      if (CGDisplayIsBuiltin(target)) {
        fprintf(stderr, "monictl: refusing to recover a built-in display\n");
        result = 1;
      } else {
        delete_cached_id(uuid);
        printf("monictl: external display is already enabled\n");
        result = 0;
      }
    } else if (target_online) {
      result = enable_online_display(configure, target, uuid);
    } else {
      result = enable_candidate(configure, uuid, recovery_id);
    }
  } else if (target_online && display_enabled(target)) {
    result = disable_display(configure, &displays, target, uuid);
  } else if (target_online) {
    result = enable_online_display(configure, target, uuid);
  } else {
    CGDirectDisplayID cached = kCGNullDirectDisplay;
    if (!read_cached_id(uuid, &cached)) {
      fprintf(stderr,
              "monictl: display %s is offline and has no cached session ID; "
              "run 'moni recover' once or log out\n",
              uuid);
      result = 1;
    } else {
      result = enable_candidate(configure, uuid, cached);
    }
  }

  close(operation_lock);
  return result;
}
