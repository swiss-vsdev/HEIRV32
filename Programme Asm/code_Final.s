# ============================================================
#  x30 : écriture = allume LEDs (bit N = LED N)
#  x31 : lecture  = état boutons (bit 0 = S0, bit 1 = S1)
# ============================================================

_start:
	addi sp, zero, 0x500        # Stack base address == 0x500
    # Attends appui sur S1 (bit 1 de x31)

wait_press:
    andi  t0, x31, 1         # isoler S0
    andi  t4, x31, 2         # isoler S1
    add   t5, t0, t4
    beq   t5, zero, wait_press   # rien appuyé → attendre

    # S0 appuyé → chenille
    slt   t6, zero, t0       # t6 = (t0 > 0)
    beq   t6, zero, check_s1
    jal   ra, chenille
    jal   zero, wait_release

check_s1:
    # S1 appuyé → pwd
    slt   t6, zero, t4       # t6 = (t4 > 0)
    beq   t6, zero, wait_press
    jal   ra, pwd

wait_release:
    andi  t0, x31, 1
    andi  t4, x31, 2
    add   t5, t0, t4
    beq   t5, zero, _start   # relâché → retour start
    jal   zero, wait_release

# ============================================================
#  chenille : LED0→LED7 puis LED7→LED0, aller-retour
# ============================================================

chenille:
    addi  sp, sp, -4
    sw    ra, 0(sp)        # Sauvegarder return address sur la pile

    # Aller : LED0 → LED7
    addi  s0, zero, 1      # s0 = masque courant (LED0 = bit 0)
    addi  s1, zero, 0      # s1 = 0 -- Compteur
    addi  s2, zero, 8      # s2 = 8 (val max)

go_right:
    add   x30, zero, s0    # Allumer LED courante
    jal   ra, delay        # Attendre 65k cycles

    slli  s0, s0, 1        # Décaler vers la gauche
    addi  s1, s1, 1        # Compteur += 1

    sub   t2, s2, s1       # t2 = 8 - compteur

    beq   t2, zero, go_left_init   # Si t2 == 0 : Arrêter à LED7 (8 décalages)
    jal   zero, go_right

go_left_init:
    # Retour : LED7 → LED0
    # s0 est maintenant à 0x100 (trop loin), revenir à LED7
    srli  s0, s0, 1        # s0 = 0x80 = LED7
    addi  s1, zero, 0      # Réinitialiser compteur

go_left:
    add   x30, zero, s0    # Allumer LED courante
    jal   ra, delay        # Attendre 65k cycles

    srli  s0, s0, 1        # Décaler vers la droite
    addi  s1, s1, 1        # Compteur += 1

    sub   t2, s2, s1       # t2 = 8 - compteur

    beq   t2, zero, end_chenille # Si t2 == 0 : Arrêter à LED0 (8 décalages)
    jal   zero, go_left

end_chenille:
    add   x30, zero, zero  # Éteindre toutes les LEDs

    lw    ra, 0(sp)        # return address = sp(0)
    addi  sp, sp, 4        # sp back to origin
    jalr  zero, ra, 0      # jump back to ra

# ============================================================
#  delay : boucle d'attente (65504 cycles)
# ============================================================

delay:
    addi  sp, sp, -4
    sw    ra, 0(sp)			# Sauvegarder return address sur la pile

    # Charger 65504 dans t3
	addi t3, zero, 0x7ff      # Charger 2047 sur t3
	slli t3, t3, 5          # t3 = t3 * 2^5 (=65504)

delayloop:
	# Dénombrer de 65504 à 0
	beq t3, zero, delay_done # Si t3 == 0, goto delay_done
	addi t3, t3, -1          # t3 = t3 - 1 

	jal zero, delayloop      # loop back to delayloop
	

delay_done:
    lw    ra, 0(sp)          # return address = sp(0)
    addi  sp, sp, 4          # sp back to origin
    jalr  zero, ra, 0        # jump back to ra


# ============================================================
#  PWD
# ============================================================

pwd:
    addi  t4, zero, 16       # duty = 16/32

pwd_loop:
    addi  x30, zero, 1       # LED ON
    add   t3, zero, t4
on_loop:
    addi  t3, t3, -1
    beq   t3, zero, off

off:
    addi  x30, zero, 0       # LED OFF
    addi  t5, zero, 32
    sub   t3, t5, t4
off_loop:
    addi  t3, t3, -1
    beq   t3, zero, btns

btns:
    andi  t0, x31, 1         # S0 = moins
    andi  t1, x31, 2         # S1 = plus

    # S0 + S1 ensemble → quitter pwd
    add   t5, t0, t1
    addi  t6, zero, 3
    beq   t5, t6, pwd_exit   # si les deux appuyés → retour

    beq   t0, zero, s1
    addi  t4, t4, -1
s1:
    beq   t1, zero, pwd_loop
    addi  t4, t4, 1
    jal   zero, pwd_loop

pwd_exit:
    addi  x30, zero, 0       # éteindre LED
    jalr  zero, ra, 0        # retour au caller