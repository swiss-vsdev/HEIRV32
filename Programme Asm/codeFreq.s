# ============================================================
#  x30 : écriture = allume LEDs (bit N = LED N)
#  x31 : lecture  = état boutons (bit 0 = S0, bit 1 = S1)
# ============================================================

_start:
	addi sp, zero, 0x500        # stack base address == 0x500
    # attends appui sur S1 (bit 1 de x31)
    # initialiser s3 à 5
    addi  s3, zero, 5       # s3 = 5, variable pour la vitesse de la chenille
    addi  s4, zero, 0       # stop flag = 0

wait_s1:
    andi  t0, x31, 1         # isoler bit 0 (bouton S1)
    beq   t0, zero, wait_s1  # tant que S1 n'est pas pressé, continuer d'écouter

release_s1:
    andi  t0, x31, 1
    beq   t0, zero, done_release    # on attend que le boutton S1 soit relâché
    jal   zero, release_s1
done_release:

run_loop:
    jal   ra, chenille                  # démarrage de la chenille
    beq   s4, zero, run_loop        # tant que le stop flag (s4) est à zéro, on continue
    jal   zero, _start                  # sinon, on revient au début du programme

# ============================================================
#  chenille : LED0→LED7 puis LED7→LED0, aller-retour
# ============================================================

chenille:
    addi  sp, sp, -4
    sw    ra, 0(sp)        # sauvegarder return address sur la pile

    # Aller : LED0 → LED7
    addi  s0, zero, 1      # s0 = masque courant (LED0 = bit 0)
    addi  s1, zero, 0      # s1 = 0 -- Compteur
    addi  s2, zero, 8      # s2 = 8 (val max)

go_right:
    add   a1, zero, s3     # s3 = 5 (2^5 = 32) pour faire 65504 cycles de delay
    jal   ra, wait_buttons      # attendre appui sur S1 pour incrémenter delay

    beq   s4, zero, not_stopped_right    # si stop flag = 0, continuer la chenille
    jal   zero, end_prog           # sinon saut vers fin du programme
    not_stopped_right:

    add   x30, zero, s0    # allumer LED courante
    add   s3, zero, a0     # s3 = 5 (2^5 = 32) pour faire 65504 cycles de delay
    jal   ra, delay        # attendre 65k cycles

    slli  s0, s0, 1        # décaler vers la gauche
    addi  s1, s1, 1        # compteur += 1

    sub   t2, s2, s1       # t2 = 8 - compteur

    beq   t2, zero, go_left_init   # si t2 == 0 : Arrêter à LED7 (8 décalages)
    jal   zero, go_right

go_left_init:
    # retour : LED7 → LED0
    # s0 est maintenant à 0x100 (trop loin), revenir à LED7
    srli  s0, s0, 1        # s0 = 0x80 = LED7
    addi  s1, zero, 0      # réinitialiser compteur

go_left:
    add   a1, zero, s3     # s3 = 5 (2^5 = 32) pour faire 65504 cycles de delay
    jal   ra, wait_buttons      # attendre appui sur S1 pour incrémenter delay

    beq   s4, zero, not_stopped_left    # si stop flag = 0, continuer la chenille
    jal   zero, end_prog           # else stop
    not_stopped_left:

    add   x30, zero, s0    # allumer LED courante
    add   s3, zero, a0     # s3 = 5 (2^5 = 32) pour faire 65504 cycles de delay
    jal   ra, delay        # attendre 65k cycles

    srli  s0, s0, 1        # décaler vers la droite
    addi  s1, s1, 1        # compteur += 1

    sub   t2, s2, s1       # t2 = 8 - compteur

    beq   t2, zero, end_prog # si t2 == 0 : Arrêter à LED0 (8 décalages)
    jal   zero, go_left

end_prog:
    add   x30, zero, zero  # éteindre toutes les LEDs

    lw    ra, 0(sp)        # return address = sp(0)
    addi  sp, sp, 4        # réinitialiser sp
    jalr  zero, ra, 0      # retourner à ra

# ============================================================
#  delay : boucle d'attente (65504 cycles)
# ============================================================

delay:
    addi  sp, sp, -4
    sw    ra, 0(sp)			# sauvegarder return address sur la pile

    # Charger 65504 dans t3
	addi t3, zero, 0x7ff      # charger 2047 sur t3
	sll t3, t3, a0          # t3 = t3 * 2^(a0) (=65504)

delayloop:
	# Dénombrer de 65504 à 0
	beq t3, zero, delay_done # si t3 == 0, goto delay_done
	addi t3, t3, -1          # t3 = t3 - 1 

	jal zero, delayloop      # retourner au début de la boucle delayloop
	
delay_done:
    lw    ra, 0(sp)          # return address = sp(0)
    addi  sp, sp, 4          # réinitialiser sp
    jalr  zero, ra, 0        # retourner à ra


# ============================================================
#  incrémenter/décrémenter longueur de delay
# ============================================================
wait_buttons:
    addi  sp, sp, -4
    sw    ra, 0(sp)			# sauvegarder return address sur la pile

    # Stop button S3
    andi  t0, x31, 4            # isoler bit 2 (bouton S3)
    beq   t0, zero, no_stop     # si S3 n'est pas pressé, continuer la chenille
    addi  s4, zero, 1           # sinon, mettre le stop flage (s4) à 1

no_stop:
    add   a0, zero, a1

    andi  t0, x31, 2            # isoler bit 1 (bouton S2)
    beq   t0, zero, check_s1    # si le bouton S2 n'est pas pressé, vérifier S1

    # if t0 == 1 : incrémenter delay
    add   a0, zero, a1
    jal   ra, incr_delay

wait_release_s2:
    andi  t0, x31, 2                    # isoler bit 1 (bouton S2)
    beq   t0, zero, done_release_s2     # si le S2 n'est plus pressé, il a donc été relâché
    jal   zero, wait_release_s2         # si S2 est toujours pressé, attendre son relâchement
done_release_s2:
    jal   zero, end_wait_buttons

check_s1:
    andi  t0, x31, 1         # isoler bit 0 (bouton S1)
    beq   t0, zero, end_wait_buttons # si S1 n'est pas pressé, terminer la boucle de contrôle des boutons

    # if t0 == 1 : décrémenter delay
    beq s3, zero, end_wait_buttons # si s3 == 0, ne pas décrémenter

    add a0, zero, a1
    jal   ra, decr_delay

wait_release_s1:
    andi  t0, x31, 1
    beq   t0, zero, done_release_s1
    jal   zero, wait_release_s1
done_release_s1:

    end_wait_buttons:
    lw    ra, 0(sp)          # return address = sp(0)
    addi  sp, sp, 4          # réinitialiser sp
    jalr zero, ra, 0         # retourner à ra

incr_delay:
    addi a0, a0, 1           # incrémenter la vitesse de 1 : a0 = a0 + 1
    jalr zero, ra, 0         # retourner à ra

decr_delay:
    addi a0, a0, -1          # décrémenter la vitesse de 1 : a0 = a0 - 1
    jalr zero, ra, 0         # retourner à ra