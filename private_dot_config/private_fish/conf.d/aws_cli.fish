alias aws_start="aws ec2 start-instances --instance-ids i-0c09a21e5bc360eb1"
alias aws2_start="aws ec2 start-instances --instance-ids i-0852cb1d188d872b7"
alias aws_stop="aws ec2 stop-instances --instance-ids i-0c09a21e5bc360eb1"
alias aws2_stop="aws ec2 stop-instances --instance-ids i-0852cb1d188d872b7"
alias aws_ssh="ssh antonio@35.167.70.130 -A"

function aws_puente
    ssh -fAN -C -L 0.0.0.0:$argv:10.2.2.30:$argv antonio@35.167.70.130
end
