# ============================================================
#  x30 : écriture = allume LEDs (bit N = LED N)
#  x31 : lecture  = état boutons (bit 0 = S0, bit 1 = S1)
# ============================================================

_start:
	addi sp, sp, 0x500        # Stack base address == 0x500
    # Attends appui sur S1 (bit 1 de x31) ----

wait_s0:
    andi  t0, x31, 1         # Isoler bit 0 (bouton S0)
    beq   t0, zero, _start   # attendre que S0 soit relâché avant de recommencer
    beq   t0, zero, wait_s0  # while t0 == 0, goto wait_s0

    # if t0 == 1 : Lancer la chenille
    jal   ra, chenille

    # Retour attente S1
    jal   zero, _start     # goto _start

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
	addi t3, t3, 0x7ff      # Charger 2047 sur t3
	slli t3, t3, 5          # t3 = t3 * 2^5 (=65504)

delayloop:
	# Dénombrer de 65504 à 0
	beq t3, zero, delay_done # Si t3 == 0, goto delay_done
	addi t3, t3, -1          # t3 = t3 - 1 

	jal zero, delayloop      # loop back to delayloopss
	

delay_done:
    lw    ra, 0(sp)          # return address = sp(0)
    addi  sp, sp, 4          # sp back to origin
    jalr  zero, ra, 0        # jump back to ra