# Copy a file's contents to the clipboard: pc <path>
function pc --description 'Copy file contents to the clipboard'
    pbcopy <$argv[1]
end
