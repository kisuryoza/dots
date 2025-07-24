#pragma once

#define DEBOUNCE 5

//#define USE_MATRIX_I2C

#define TAPPING_TERM 200
#define QUICK_TAP_TERM 0
#define PERMISSIVE_HOLD
#define BOTH_SHIFTS_TURNS_ON_CAPS_WORD

#ifdef RGBLIGHT_ENABLE
    #define RGBLIGHT_EFFECT_BREATHING
    #define RGBLIGHT_EFFECT_RAINBOW_MOOD
    #define RGBLIGHT_EFFECT_RAINBOW_SWIRL
    #define RGBLIGHT_EFFECT_SNAKE
    #define RGBLIGHT_EFFECT_KNIGHT
    #define RGBLIGHT_EFFECT_CHRISTMAS
    #define RGBLIGHT_EFFECT_STATIC_GRADIENT
    #define RGBLIGHT_EFFECT_RGB_TEST
    #define RGBLIGHT_EFFECT_ALTERNATING
    #define RGBLIGHT_EFFECT_TWINKLE
    #define RGBLIGHT_LIMIT_VAL 120
    #define RGBLIGHT_HUE_STEP 10
    #define RGBLIGHT_SAT_STEP 17
    #define RGBLIGHT_VAL_STEP 17
#endif

#ifdef RGB_MATRIX_ENABLE
    #define RGB_MATRIX_KEYPRESSES // reacts to keypresses
    // #define RGB_MATRIX_KEYRELEASES // reacts to keyreleases (instead of keypresses)
    #define RGB_MATRIX_SLEEP // turn off effects when suspended
    #define RGB_MATRIX_FRAMEBUFFER_EFFECTS
    // #define RGB_MATRIX_LED_PROCESS_LIMIT (RGB_MATRIX_LED_COUNT + 4) / 5 // limits the number of LEDs to process in an animation per task run (increases keyboard responsiveness)
    // #define RGB_MATRIX_LED_FLUSH_LIMIT 16 // limits in milliseconds how frequently an animation will update the LEDs. 16 (16ms) is equivalent to limiting to 60fps (increases keyboard responsiveness)
    #define RGB_MATRIX_MAXIMUM_BRIGHTNESS 120 // limits maximum brightness of LEDs to 150 out of 255. Higher may cause the controller to crash.
    #define RGB_MATRIX_HUE_STEP 8
    #define RGB_MATRIX_SAT_STEP 8
    #define RGB_MATRIX_VAL_STEP 8
    #define RGB_MATRIX_SPD_STEP 10
    #define RGB_MATRIX_DEFAULT_MODE RGB_MATRIX_SOLID_REACTIVE_MULTIWIDE

    // https://docs.qmk.fm/#/feature_rgb_matrix?id=rgb-matrix-effects
    #define ENABLE_RGB_MATRIX_SOLID_COLOR     // Static single hue, no speed support
    #undef ENABLE_RGB_MATRIX_ALPHAS_MODS         // Static dual hue, speed is hue for secondary hue
    #undef ENABLE_RGB_MATRIX_GRADIENT_UP_DOWN    // Static gradient top to bottom, speed controls how much gradient changes
    #undef ENABLE_RGB_MATRIX_GRADIENT_LEFT_RIGHT    // Static gradient left to right, speed controls how much gradient changes
    #undef ENABLE_RGB_MATRIX_BREATHING           // Single hue brightness cycling animation
    #undef ENABLE_RGB_MATRIX_BAND_SAT        // Single hue band fading saturation scrolling left to right
    #undef ENABLE_RGB_MATRIX_BAND_VAL        // Single hue band fading brightness scrolling left to right
    #undef ENABLE_RGB_MATRIX_BAND_PINWHEEL_SAT   // Single hue 3 blade spinning pinwheel fades saturation
    #undef ENABLE_RGB_MATRIX_BAND_PINWHEEL_VAL   // Single hue 3 blade spinning pinwheel fades brightness
    #undef ENABLE_RGB_MATRIX_BAND_SPIRAL_SAT     // Single hue spinning spiral fades saturation
    #undef ENABLE_RGB_MATRIX_BAND_SPIRAL_VAL     // Single hue spinning spiral fades brightness
    #undef ENABLE_RGB_MATRIX_CYCLE_ALL           // Full keyboard solid hue cycling through full gradient
    #undef ENABLE_RGB_MATRIX_CYCLE_LEFT_RIGHT    // Full gradient scrolling left to right
    #undef ENABLE_RGB_MATRIX_CYCLE_UP_DOWN       // Full gradient scrolling top to bottom
    #undef ENABLE_RGB_MATRIX_CYCLE_OUT_IN        // Full gradient scrolling out to in
    #undef ENABLE_RGB_MATRIX_CYCLE_OUT_IN_DUAL   // Full dual gradients scrolling out to in
    #undef ENABLE_RGB_MATRIX_RAINBOW_MOVING_CHEVRON  // Full gradient Chevron shapped scrolling left to right
    #undef ENABLE_RGB_MATRIX_CYCLE_PINWHEEL      // Full gradient spinning pinwheel around center of keyboard
    #undef ENABLE_RGB_MATRIX_CYCLE_SPIRAL        // Full gradient spinning spiral around center of keyboard
    #undef ENABLE_RGB_MATRIX_DUAL_BEACON         // Full gradient spinning around center of keyboard
    #undef ENABLE_RGB_MATRIX_RAINBOW_BEACON      // Full tighter gradient spinning around center of keyboard
    #undef ENABLE_RGB_MATRIX_RAINBOW_PINWHEELS   // Full dual gradients spinning two halfs of keyboard
    #define ENABLE_RGB_MATRIX_FLOWER_BLOOMING     // Full tighter gradient of first half scrolling left to right and second half scrolling right to left
    #undef ENABLE_RGB_MATRIX_RAINDROPS           // Randomly changes a single key's hue
    #undef ENABLE_RGB_MATRIX_JELLYBEAN_RAINDROPS // Randomly changes a single key's hue and saturation
    #undef ENABLE_RGB_MATRIX_HUE_BREATHING       // Hue shifts up a slight ammount at the same time, then shifts back
    #undef ENABLE_RGB_MATRIX_HUE_PENDULUM        // Hue shifts up a slight ammount in a wave to the right, then back to the left
    #undef ENABLE_RGB_MATRIX_HUE_WAVE            // Hue shifts up a slight ammount and then back down in a wave to the right
    #undef ENABLE_RGB_MATRIX_PIXEL_FRACTAL       // Single hue fractal filled keys pulsing horizontally out to edges
    #undef ENABLE_RGB_MATRIX_PIXEL_FLOW          // Pulsing RGB flow along LED wiring with random hues
    #undef ENABLE_RGB_MATRIX_PIXEL_RAIN          // Randomly light keys with random hues
    // enabled only if RGB_MATRIX_FRAMEBUFFER_EFFECTS is defined
    #define ENABLE_RGB_MATRIX_TYPING_HEATMAP      // How hot is your WPM!
    #undef ENABLE_RGB_MATRIX_DIGITAL_RAIN        // That famous computer simulation
    // enabled only of RGB_MATRIX_KEYPRESSES or RGB_MATRIX_KEYRELEASES is defined
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_SIMPLE   // Pulses keys hit to hue & value then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE      // Static single hue, pulses keys hit to shifted hue then fades to current hue
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_WIDE       // Hue & value pulse near a single key hit then fades value out
    #define ENABLE_RGB_MATRIX_SOLID_REACTIVE_MULTIWIDE  // Hue & value pulse near multiple key hits then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_CROSS      // Hue & value pulse the same column and row of a single key hit then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_MULTICROSS // Hue & value pulse the same column and row of multiple key hits then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_NEXUS      // Hue & value pulse away on the same column and row of a single key hit then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_REACTIVE_MULTINEXUS // Hue & value pulse away on the same column and row of multiple key hits then fades value out
    #undef ENABLE_RGB_MATRIX_SPLASH              // Full gradient & value pulse away from a single key hit then fades value out
    #define ENABLE_RGB_MATRIX_MULTISPLASH         // Full gradient & value pulse away from multiple key hits then fades value out
    #undef ENABLE_RGB_MATRIX_SOLID_SPLASH        // Hue & value pulse away from a single key hit then fades value out
    #define ENABLE_RGB_MATRIX_SOLID_MULTISPLASH   // Hue & value pulse away from multiple key hits then fades value out
    #undef ENABLE_RGB_MATRIX_STARLIGHT           // LEDs turn on and off at random at varying brightness, maintaining user set color
    #undef ENABLE_RGB_MATRIX_STARLIGHT_SMOOTH    // LEDs slowly increase and decrease in brightness randomly
    #undef ENABLE_RGB_MATRIX_STARLIGHT_DUAL_HUE  // LEDs turn on and off at random at varying brightness, modifies user set hue by +- 30
    #undef ENABLE_RGB_MATRIX_STARLIGHT_DUAL_SAT  // LEDs turn on and off at random at varying brightness, modifies user set saturation by +- 30
    #define ENABLE_RGB_MATRIX_RIVERFLOW           // Modification to breathing animation, offset's animation depending on key location to simulate a river flowing
#endif
