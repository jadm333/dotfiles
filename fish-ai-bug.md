
# fish-ai fails with Anthropic ThinkingBlock responses

## Summary

`Realiserad/fish-ai` crashes when an Anthropic model returns a `ThinkingBlock` as the first content block. The plugin assumes the first response block always has a `.text` attribute.

## Environment

- macOS
- Fish with Fisher
- `realiserad/fish-ai` installed through Fisher
- Python 3.14 virtual environment managed by fish-ai at `~/.local/share/fish-ai`
- Anthropic provider
- Model that reproduced the problem: `claude-sonnet-5`

## Sanitized configuration

```ini
[fish-ai]
configuration = anthropic

[anthropic]
provider = anthropic
api_key = "REDACTED"
model = claude-sonnet-5
```

## Reproduction

1. Configure fish-ai with the Anthropic provider and `claude-sonnet-5`.
2. Trigger fish-ai with one of its normal keybindings.
3. fish-ai fails before returning a response.

## Actual result

```text
An error occurred when running fish-ai. More info: ("'ThinkingBlock' object has no attribute 'text'",)
```

## Expected result

fish-ai should extract text blocks from the Anthropic response and either ignore thinking blocks or handle them explicitly.

## Suspected cause

In the installed fish-ai package, `fish_ai/engine.py` uses:

```python
completions = client.messages.create(**params)
response = completions.content[0].text
```

When a model emits a `ThinkingBlock` before its text response, `completions.content[0]` is not a text block and does not expose `.text`.

## Workaround

Using the project’s documented Anthropic model, `claude-sonnet-4-6`, avoids the crash. The chezmoi template has been changed to use that model.

## Suggested fix

Select text blocks safely instead of assuming the first block is text, for example by filtering `completions.content` for blocks with `type == "text"` and joining their text values. If thinking blocks need preservation, handle them according to Anthropic’s Messages API response types.
