require("rgb_setup")
require("wifi_setup")
require("mqtt_setup")


blink(boot_light_tmr_id, {0, 0, 0}, {0, 255, 0}, 500)

init_wifi()
init_mqtt()
