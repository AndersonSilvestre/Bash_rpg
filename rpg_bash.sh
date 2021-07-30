#!/bin/bash
#
# Simples RPG em bash v1.0
# Criado em alguma horas no dia 27/2/2017
# por xerxeslins (xerxeslins@gmail.com)
# www.vivaolinux.com.br/~xerxeslins
#        ---- // -----
#
# Em atualização por Anderson Silvestre
# https://github.com/AndersonSilvestre
#
# GLP

NIVEL=1
EXP=0
NEXT=10
DUNGEON=1
POTION=1
KILL=0
COMBATE=0
ESCADA=0
SAUDE_ID=4
DANO_ARMA=1
VIDA_MONSTRO=3
SAUDE=("Mal consegue andar." "Com cortes profundos e hematomas" "Com cortes" "Com arranhões" "Saudável")

function _comandos () {
	echo "Comandos:"
	echo "(a)tacar (b)eber (c)omandos (d)escer (e)xplorar (f)ugir (p)ersonagem (s)air"
	_menu
}

function _personagem () {
	echo "$NOME [${SAUDE[SAUDE_ID]}] nível $NIVEL, experiência $EXP/$NEXT, dungeon $DUNGEON, poções $POTION, matou $KILL."
	_menu
}

function _sair () {
	echo "$NOME se perdeu na dungeon e nunca mais retornou..."
	exit 0
}

function _dado {
	DT=$(( ( RANDOM % 6) + 1 ))
}

function _testa_morte_personagem () {
	if [ $SAUDE_ID -le 0 ]
		then
			echo "$NOME morreu!!!
			
R.I.P.

Nível: $NIVEL
Dungeon: $DUNGEON
Poções: $POTION
Matou: $KILL"
		exit 0
	fi
}

			#### Monstros
function _monstro_ataca () {
	_dado
	if [ $DT -lt 5 ] 
		then
			echo "$NOME se desviou do ataque do monstro!"
	else
		echo "$NOME sofreu o ataque do monstro!"
		SAUDE_ID=$(( $SAUDE_ID - 1 ))
		_testa_morte_personagem
	fi
	_menu	
}

function _monstro_forte (){
		_dado
	if [ $DT -lt 5 ] 
		then
			echo "$NOME se desviou do ataque do monstro-forte!"
	else
		echo "$NOME sofreu o ataque do monstro-forte!"
		SAUDE_ID=$(( $SAUDE_ID - 2 ))
		_testa_morte_personagem
	fi
	_menu	
}
			########

function _testa_evolucao () {
	if [ $EXP -ge $NEXT ]
		then
			NIVEL=$(( $NIVEL + 1 ))
			NEXT=$(( $NEXT + (( 1 + $NIVEL ) * 5) ))
			DANO_ARMA=$(( DANO_ARMA + 1 ))
			echo "$NOME se sente mais forte!"
	fi	
}

function _personagem_acerta {
	echo "$NOME atingiu o monstro!"
	_dado	
	if [ $VIDA_MONSTRO -le 0 ]
		then
			echo "$NOME matou o monstro!"
			VIDA_MONSTRO=2
			COMBATE=0
			KILL=$(( $KILL + 1 ))
			EXP=$(( $EXP + ( RANDOM % 4) + $DUNGEON ))
			_testa_evolucao
	elif [ $NIVEL -ge 3 ]
		then
		#statements
		echo "Vida Monstro $VIDA_MONSTRO"
		echo "Dano da arma $DANO_ARMA"
		echo "Dano do monstro 2 sua vida [${SAUDE[SAUDE_ID]}]"
		_monstro_forte
	else
		echo "Vida Monstro $VIDA_MONSTRO"
		echo "Dano da arma $DANO_ARMA"
		_monstro_ataca
	fi
}

function _atacar () {
	if [ $COMBATE -eq 0 ]
		then
			echo "$NOME desfere um golpe com a espada, cortando o ar!"
	else
		_dado
		DIFICULDADE=$(( 3 + $NIVEL - $DUNGEON ))
		if [ $DT -le $DIFICULDADE ]
			then
				VIDA_MONSTRO=$(( $VIDA_MONSTRO - $DANO_ARMA ))
				echo "dado $DT"
				_personagem_acerta
			else
				echo "$NOME errou o ataque!"
				_monstro_ataca	
		fi
	fi
	_menu
}

function _beber () {
	if [ $POTION -gt 0 ]
		then
			echo "$NOME bebe uma poção e se sente muito bem!"
			POTION=$(( $POTION - 1 ))
			SAUDE_ID=4
		else
			echo "$NOME procura uma poção na mochila, mas não encontra."
	fi
	_menu
}

function _explorar () {
	if [ $COMBATE -eq 0 ]
		then
			_dado
			if [ $DT -gt 4 ] && [ $NIVEL -le 2 ]
				then
					echo "$NOME encontrou um monstro!"
					COMBATE=1
			elif [ $DT -gt 4 ] && [ $NIVEL -ge 3 ]
				then
					echo "Encontrou o monstro-forte"
					COMBATE=1
			elif [ $DT -lt 2 ]
				then
					if [ $ESCADA -eq 0 ]
						then
							echo "$NOME encontrou escadas que levam para o próximo nível da dungeon."
							ESCADA=1
						else
							echo "$NOME encontrou uma poção e guardou na mochila."
							POTION=$(( $POTION + 1 ))
					fi
			else
				echo "$NOME explora o interior da dungeon..."
			fi		
		else
			echo "$NOME está no meio do combate e não pode explorar agora!"
	fi
	_menu
}

function _descer () {
	if [ $ESCADA -eq 1 ]
		then
			echo "$NOME desceu as escadas."
			DUNGEON=$(( $DUNGEON + 1 ))
			ESCADA=0
		else
			echo "$NOME olha em volta, mas não vê por onde descer."
	fi
	_menu
}

function _fugir () {
	if [ $COMBATE -eq 1 ]
		then
			_dado
			if [ $DT -lt 3 ]
				then
					echo "$NOME fugiu do monstro como uma garotinha assustada!"
					COMBATE=0
				else
					echo "$NOME procurou uma oportunidade para fugir, mas não encontrou!"
					_monstro_ataca
			fi
		else
			echo "$NOME não tem do que fugir no momento."
	fi
	_menu
}



function _menu () {
	read -p "> insira seu comando " OPT
	
	#Se quiser idle de 5 segundos descomente o trecho abaixo e comente o read acima
	#read -t 5 -p "> " OPT
	#if [ -z "$OPT" ]
	#	then
	#		if [ $COMBATE -eq 1 ]
	#			then
	#				OPT="a"
	#		else
	#			OPT="e"
	#		fi
	#	echo ""
	#fi
	
	case $OPT in
		c|comandos) _comandos;;
		p|personagem) _personagem;;
		s|sair) _sair;;
		a|ataque|atacar) _atacar;;
		b|beber) _beber;;
		e|explorar) _explorar;;
		d|descer) _descer;;
		f|fugir) _fugir;;
		*) echo "$NOME não entendeu o seu comando. (digite c para ver os comandos)"; _menu;;
	esac
}
function _start () {
	echo "Qual o nome do seu personagem?"
	read -p "> " NOME
	echo "(digite c para ver os comandos)
	
$NOME entrou na dungeon para eliminar os monstros."
	_menu
}
_start
