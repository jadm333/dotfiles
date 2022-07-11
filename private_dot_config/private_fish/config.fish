if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ssh_ngrok="ssh antonio@3.tcp.ngrok.io -p 28312 -A"

if test -e ~/.local/bin
     set PATH $PATH ~/.local/bin
end

if type -q npm
     set PATH $PATH ~/.npm-global/bin:$PATH
end

if test -e ~/bin
     set PATH $PATH ~/bin
end
