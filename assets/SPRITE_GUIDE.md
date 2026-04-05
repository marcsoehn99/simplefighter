# Sprite Sheet Guide

## Format
- Sprite Sheets: alle Frames horizontal nebeneinander in einem PNG
- Empfohlene Frame-Groesse: **128x128 px** pro Frame
- Transparenter Hintergrund (PNG mit Alpha)
- Charakter zentriert, Fuesse am unteren Rand

## Ordnerstruktur
```
assets/
  p1/                    <- Spieler 1 (blau)
    idle.png             (6 Frames = 768x128)
    walk.png             (8 Frames = 1024x128)
    jump.png             (6 Frames = 768x128)
    crouch.png           (3 Frames = 384x128)
    stand_lp.png         (8 Frames = 1024x128)
    stand_hp.png         (11 Frames = 1408x128)
    stand_lk.png         (10 Frames = 1280x128)
    stand_hk.png         (12 Frames = 1536x128)
    crouch_lp.png        (8 Frames = 1024x128)
    crouch_hp.png        (10 Frames = 1280x128)
    crouch_lk.png        (10 Frames = 1280x128)
    crouch_hk.png        (12 Frames = 1536x128)
    jump_lp.png          (8 Frames = 1024x128)
    jump_hp.png          (10 Frames = 1280x128)
    jump_lk.png          (8 Frames = 1024x128)
    jump_hk.png          (11 Frames = 1408x128)
    fireball.png         (11 Frames = 1408x128)
    dragon_punch.png     (12 Frames = 1536x128)
    hit_stun.png         (3 Frames = 384x128)
    block_stun.png       (2 Frames = 256x128)
    ko.png               (6 Frames = 768x128)
  p2/                    <- Spieler 2 (rot) - gleiche Dateinamen
    (gleiche Dateien wie p1/)
  effects/
    fireball_projectile.png  (4 Frames = 512x128)
    hit_spark.png            (4 Frames = 512x128)
    block_spark.png          (3 Frames = 384x128)
  stage/
    background.png       (1280x720 Hintergrundbild)
    floor.png            (optional, Bodentextur)
  ui/
    health_bar.png       (optional)
    portrait_p1.png      (optional, 64x64)
    portrait_p2.png      (optional, 64x64)
```

## Frame-Aufteilung pro Attack

Jede Attack-Animation hat 3 Phasen:
- **Startup**: Ausholbewegung (vor dem Treffer)
- **Active**: Schlag/Tritt trifft (Hitbox aktiv)
- **Recovery**: Zurueckziehen (verwundbar)

| Attack       | Startup | Active | Recovery | Total |
|------------- |---------|--------|----------|-------|
| stand_lp     | 3       | 2      | 3        | 8     |
| stand_hp     | 4       | 3      | 4        | 11    |
| stand_lk     | 3       | 2      | 5        | 10    |
| stand_hk     | 4       | 3      | 5        | 12    |
| crouch_lp    | 3       | 2      | 3        | 8     |
| crouch_hp    | 3       | 3      | 4        | 10    |
| crouch_lk    | 3       | 2      | 5        | 10    |
| crouch_hk    | 4       | 3      | 5        | 12    |
| jump_lp      | 3       | 2      | 3        | 8     |
| jump_hp      | 3       | 3      | 4        | 10    |
| jump_lk      | 3       | 2      | 3        | 8     |
| jump_hk      | 4       | 3      | 4        | 11    |
| fireball     | 4       | 3      | 4        | 11    |
| dragon_punch | 3       | 4      | 5        | 12    |

## Bewegungs-Animationen

| Animation  | Frames | Notizen                              |
|----------- |--------|--------------------------------------|
| idle       | 6      | Breathing/Kampfstellung-Loop         |
| walk       | 8      | Vorwaerts-Schritt-Loop               |
| jump       | 6      | Abstoss, Aufstieg, Peak, 3x Abstieg  |
| crouch     | 3      | Uebergang stehend->hockend           |
| hit_stun   | 3      | Getroffen-Reaktion                   |
| block_stun | 2      | Block-Reaktion                       |
| ko         | 6      | Umfallen + am Boden liegen           |

## Wichtig
- Alle Sprites muessen nach **rechts** schauen (wird im Code gespiegelt)
- Fuesse auf dem unteren Rand des 128px Frames
- Konsistente Koerperproportionen zwischen allen Animationen
