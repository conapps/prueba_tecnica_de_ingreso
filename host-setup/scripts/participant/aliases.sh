# Prueba técnica — aliases SSH (participante)
alias ssh-rtr='ssh demo@10.0.0.80'
alias ssh-core='ssh demo@10.0.0.81'
alias ssh-edge='ssh demo@10.0.0.82'
alias lab-ping='for i in 10.0.0.80 10.0.0.81 10.0.0.82; do ping -c1 -W2 $i && echo $i OK || echo $i FAIL; done'
