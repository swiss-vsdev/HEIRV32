# ============================================================
#  chenille.s — Effet chenille sur les LEDs
#  Instructions supportées : add, sub, and, or, slt, xor,
#    sll, srl, addi, andi, ori, slti, xori, slli, srli,
#    lw, sw, beq, jal, jalr
#
#  x30 : écriture = allume LEDs (bit N = LED N)
#  x31 : lecture  = état boutons (bit 0 = S0, bit 1 = S1)
# ============================================================

_start:
    # ---- Attendre appui sur S1 (bit 1 de x31) ----
wait_s1:
    andi  t0, x31, 2       # Isoler bit 1 (bouton S1)
    beq   t0, zero, wait_s1  # Boucler si S1 non appuyé

    # ---- Lancer la chenille ----
    jal   ra, chenille

    # ---- Revenir attendre ----
    jal   zero, _start     # j _start (pseudo = jal zero)


# ============================================================
#  chenille : LED0→LED7 puis LED7→LED0, aller-retour
# ============================================================
chenille:
    addi  sp, sp, -4
    sw    ra, 0(sp)        # Sauvegarder ra sur la pile

    # --- Aller : LED0 → LED7 ---
    addi  s0, zero, 1      # s0 = masque courant (LED0 = bit 0)
    addi  s1, zero, 0      # s1 = compteur 0..7

go_right:
    add   x30, zero, s0    # Allumer LED courante
    jal   ra, delay
    slli  s0, s0, 1        # Décaler vers la gauche
    addi  s1, s1, 1
    addi  t1, zero, 8
    sub   t2, t1, s1       # t2 = 8 - compteur
    beq   t2, zero, go_left_init   # Arrêter à LED7 (8 décalages)
    jal   zero, go_right

go_left_init:
    # --- Retour : LED7 → LED0 ---
    # s0 est maintenant à 0x100 (trop loin), revenir à LED7
    srli  s0, s0, 1        # s0 = 0x80 = LED7
    addi  s1, zero, 0      # Réinitialiser compteur

go_left:
    add   x30, zero, s0    # Allumer LED courante
    jal   ra, delay
    srli  s0, s0, 1        # Décaler vers la droite
    addi  s1, s1, 1
    addi  t1, zero, 8
    sub   t2, t1, s1
    beq   t2, zero, end_chenille
    jal   zero, go_left

end_chenille:
    add   x30, zero, zero  # Éteindre toutes les LEDs

    lw    ra, 0(sp)        # Restaurer ra
    addi  sp, sp, 4
    jalr  zero, ra, 0      # ret


# ============================================================
#  delay : boucle d'attente (~50000 cycles)
# ============================================================
delay:
    addi  sp, sp, -4
    sw    ra, 0(sp)

    # Charger 50000 dans t3 : 50000 = 0xC350
    addi  t3, zero, 1
    slli  t3, t3, 12       # t3 = 4096
    addi  t4, zero, 12
    sll   t4, t3, t4       # non valide en un coup — utiliser addi itéré

    # 50000 en deux temps : lui+addi n'est pas dispo → on boucle 200x250
    addi  t3, zero, 200    # boucle externe
delay_outer:
    addi  t4, zero, 250    # boucle interne
delay_inner:
    addi  t4, t4, -1
    beq   t4, zero, next_outer
    jal   zero, delay_inner
next_outer:
    addi  t3, t3, -1
    beq   t3, zero, delay_done
    jal   zero, delay_outer

delay_done:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    jalr  zero, ra, 0