#include QMK_KEYBOARD_H

enum layers {
    BASE = 0,
    GAM,
    SYM,
    NAV,
    NUM,
    FN,
    EXT,
};

enum keycode_aliases {
    MT_S = MT(MOD_LGUI, KC_S),
    MT_D = MT(MOD_LCTL, KC_D),
    MT_F = MT(MOD_LSFT, KC_F),

    MT_J = MT(MOD_RSFT, KC_J),
    MT_K = MT(MOD_RCTL, KC_K),
    MT_L = MT(MOD_RGUI, KC_L),

    LTB_FN = LT(FN, KC_ESC),
    LTB_NUM = LT(NUM, KC_SPC),
    LTB_NAV = LT(NAV, KC_TAB),
    LTB_EXT = LT(EXT, KC_ENT),
    LTB_SYM = LT(SYM, KC_BSPC),

    // LTB_SYM = LT(SYM, KC_BSPC)
};

const uint16_t PROGMEM combo1[] = {KC_TAB, KC_SPC, COMBO_END};
combo_t key_combos[] = {
    COMBO(combo1, MO(NUM))
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [BASE] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T, KC_VOLU,    KC_MPLY,    KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,  KC_BSPC,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_A,    MT_S,    MT_D,    MT_F,    KC_G, KC_VOLD,    KC_MSTP,    KC_H,    MT_J,    MT_K,    MT_L, KC_SCLN, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      KC_LCTL,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, QK_GESC,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                           LTB_FN, LTB_NUM, LTB_NAV,    LTB_EXT, LTB_SYM, KC_UNDS
                                      //`--------------------------'  `--------------------------'
  ),

  [GAM] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T, KC_VOLU,    KC_MPLY,    KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,  KC_BSPC,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_A,    KC_S,    KC_D,    KC_F,    KC_G, KC_VOLD,    KC_MSTP,    KC_H,    KC_J,    KC_K,    KC_L, KC_SCLN, KC_QUOT,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      KC_LCTL,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, KC_LGUI,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                           KC_ESC,  KC_SPC, LTB_NAV,    LTB_EXT, KC_BSPC, KC_UNDS
                                      //`--------------------------'  `--------------------------'
  ),

  [SYM] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
      XXXXXXX,  KC_GRV, KC_LABK, KC_RABK, KC_MINS, KC_PIPE, XXXXXXX,    XXXXXXX, KC_CIRC, KC_LCBR, KC_RCBR,  KC_DLR, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_EXLM, KC_ASTR, KC_SLSH,  KC_EQL, KC_AMPR, XXXXXXX,    XXXXXXX, KC_HASH, KC_LPRN, KC_RPRN, KC_SCLN, KC_DQUO, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_TILD, KC_PLUS, KC_LBRC, KC_RBRC, KC_PERC,                        KC_AT, KC_COLN, KC_COMM,  KC_DOT, KC_QUOT, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                           KC_ESC,  KC_SPC,  KC_TAB,     KC_ENT, _______, QK_LLCK
                                      //`--------------------------'  `--------------------------'
  ),

  [NAV] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_MUTE,    KC_MNXT, XXXXXXX,  KC_INS, KC_HOME, KC_PGUP, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LALT, KC_LGUI, KC_LCTL, KC_LSFT, XXXXXXX, XXXXXXX,    KC_MPRV, KC_LEFT, KC_DOWN,   KC_UP,KC_RIGHT, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX,  KC_DEL,  KC_END, KC_PGDN, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                           KC_ESC,  KC_SPC, _______,     KC_ENT, KC_BSPC, QK_LLCK
                                      //`--------------------------'  `--------------------------'
  ),

  [NUM] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, KC_SLSH,    KC_7,    KC_8,    KC_9, KC_ASTR, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LALT, KC_LGUI, KC_LCTL, KC_LSFT, XXXXXXX, XXXXXXX,    XXXXXXX, KC_MINS,    KC_1,    KC_2,    KC_3, KC_PLUS, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX,    KC_4,    KC_5,    KC_6, KC_PERC, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                           KC_ESC, _______,  KC_TAB,     KC_ENT,    KC_0, QK_LLCK
                                      //`--------------------------'  `--------------------------'
  ),

  [FN] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, XXXXXXX,   KC_F1,   KC_F2,   KC_F3,   KC_F4, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, KC_LALT, KC_LGUI, KC_LCTL, KC_LSFT, XXXXXXX, XXXXXXX,    XXXXXXX, XXXXXXX,   KC_F5,   KC_F6,   KC_F7,   KC_F8, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,                      XXXXXXX,   KC_F9,  KC_F10,  KC_F11,  KC_F12, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                          _______,  KC_SPC,  KC_TAB,     KC_ENT, KC_BSPC, QK_LLCK
                                      //`--------------------------'  `--------------------------'
  ),

  [EXT] = LAYOUT_split_3x6_3_ex2(
  //,--------------------------------------------------------------.  ,--------------------------------------------------------------.
     DF(BASE), DF(GAM), XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, MS_BTN3, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------|  |--------+--------+--------+--------+--------+--------+--------|
      RM_TOGG, RM_HUEU, RM_SATU, RM_VALU, XXXXXXX, XXXXXXX, XXXXXXX,    XXXXXXX, MS_LEFT, MS_DOWN,   MS_UP, MS_RGHT, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------'  `--------+--------+--------+--------+--------+--------+--------|
      RM_NEXT, RM_HUED, RM_SATD, RM_VALD, XXXXXXX, XXXXXXX,                      MS_WHLL, MS_WHLD, MS_WHLU, MS_WHLR, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------+--------.  ,--------+--------+--------+--------+--------+--------+--------|
                                          XXXXXXX, MS_BTN1, XXXXXXX,    _______, MS_BTN2, QK_LLCK
                                      //`--------------------------'  `--------------------------'
  )
};

#ifdef ENCODER_MAP_ENABLE
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
  [0] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [1] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [2] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
  [3] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU), ENCODER_CCW_CW(KC_MPRV, KC_MNXT), ENCODER_CCW_CW(RM_VALD, RM_VALU), ENCODER_CCW_CW(KC_RGHT, KC_LEFT), },
};
#endif
