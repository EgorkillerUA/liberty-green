#define DRONE_PRODUCTION "production"
#define DRONE_RECHARGING "recharging"
#define DRONE_READY "ready"

/obj/machinery/droneDispenser //Most customizable machine 2015
	name = "drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, \
		will periodically create a drone shell. \
		Does not need to be manually operated."

	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "on"
	anchored = 1
	density = 1

	var/health = 100
	var/max_health = 100

	// These allow for different icons when creating custom dispensers
	var/icon_off = "off"
	var/icon_on = "on"
	var/icon_recharging = "recharge"
	var/icon_creating = "make"

	var/datum/material_container/materials
	var/list/using_materials
	var/metal_cost = 1000
	var/glass_cost = 1000
	var/power_used = 1000

	var/mode = DRONE_READY
	var/timer
	var/cooldownTime = 1800 //3 minutes
	var/production_time = 30
	//The item the dispenser will create
	var/dispense_type = /obj/item/drone_shell

	// The maximum number of "idle" drone shells it will make before
	// ceasing production. Set to 0 for infinite.
	var/maximum_idle = 3

	var/work_sound = 'sound/items/rped.ogg'
	var/create_sound = 'sound/items/Deconstruct.ogg'
	var/recharge_sound = 'sound/machines/ping.ogg'

	var/begin_create_message = "whirs to life!"
	var/end_create_message = "dispenses a drone shell."
	var/recharge_message = "pings."
	var/recharging_text = "It is whirring and clicking. \
		It seems to be recharging."

	var/break_message = "lets out a tinny alarm before falling dark."
	var/break_sound = 'sound/machines/warning-buzzer.ogg'

/obj/machinery/droneDispenser/New()
	..()
	health = max_health
	materials = new(src, list(MAT_METAL, MAT_GLASS),
		MINERAL_MATERIAL_AMOUNT*MAX_STACK_SIZE*2)

	using_materials = list(MAT_METAL=metal_cost, MAT_GLASS=glass_cost)

/obj/machinery/droneDispenser/Destroy()
	qdel(materials)
	. = ..()

/obj/machinery/droneDispenser/preloaded/New()
	..()
	materials.insert_amount(5000)

/obj/machinery/droneDispenser/syndrone //Please forgive me
	name = "syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate \
		exterminator drones when supplied with metal and glass. Disgusting."
	dispense_type = /obj/item/drone_shell/syndrone
	//If we're gonna be a jackass, go the full mile - 10 second recharge timer
	cooldownTime = 100
	end_create_message = "dispenses a suspicious drone shell."

/obj/machinery/droneDispenser/syndrone/New()
	..()
	materials.insert_amount(25000)

/obj/machinery/droneDispenser/syndrone/badass //Please forgive me
	name = "badass syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate \
		exterminator drones when supplied with metal and glass. \
		Disgusting. This one seems ominous."
	dispense_type = /obj/item/drone_shell/syndrone/badass
	end_create_message = "dispenses a ominous suspicious drone shell."

// I don't need your forgiveness, this is awesome.
/obj/machinery/droneDispenser/snowflake
	name = "snowflake drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, \
		will periodically create a snowflake drone shell. \
		Does not need to be manually operated."
	dispense_type = /obj/item/drone_shell/snowflake
	end_create_message = "dispenses a snowflake drone shell."
	// Those holoprojectors aren't cheap
	metal_cost = 2000
	glass_cost = 2000
	power_used = 2000

/obj/machinery/droneDispenser/snowflake/preloaded/New()
	..()
	materials.insert_amount(10000)

// An example of a custom drone dispenser.
// This one requires no materials and creates basic hivebots
/obj/machinery/droneDispenser/hivebot
	name = "hivebot fabricator"
	desc = "A large, bulky machine that whirs with activity, \
		steam hissing from vents in its sides."
	icon = 'icons/obj/objects.dmi'
	icon_state = "hivebot_fab"
	icon_off = "hivebot_fab"
	icon_on = "hivebot_fab"
	icon_recharging = "hivebot_fab"
	icon_creating = "hivebot_fab_on"
	metal_cost = 0
	glass_cost = 0
	power_used = 0
	cooldownTime = 10 //Only 1 second - hivebots are extremely weak
	dispense_type = /mob/living/simple_animal/hostile/hivebot
	begin_create_message = "closes and begins fabricating something within."
	end_create_message = "slams open, revealing out a hivebot!"
	recharge_sound = null
	recharge_message = null

/obj/machinery/droneDispenser/swarmer
	name = "swarmer fabricator"
	desc = "An alien machine of unknown origin. \
		It whirs and hums with green-blue light, the air above it shimmering."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "toffcenter"
	icon_off = "toffcenter"
	icon_on = "toffcenter"
	icon_recharging = "toffcenter"
	icon_creating = "offcenter"
	metal_cost = 0
	glass_cost = 0
	cooldownTime = 300 //30 seconds
	maximum_idle = 0 // Swarmers have no restraint
	dispense_type = /obj/item/device/unactivated_swarmer
	begin_create_message = "hums softly as an interface appears above it, \
		scrolling by at unreadable speed."
	end_create_message = "materializes a strange shell, which drops to the \
		ground."
	recharging_text = "Its lights are slowly increasing in brightness."
	work_sound = 'sound/effects/EMPulse.ogg'
	create_sound = 'sound/effects/phasein.ogg'
	break_sound = 'sound/effects/EMPulse.ogg'
	break_message = "slowly falls dark, lights stuttering."

/obj/machinery/droneDispenser/examine(mob/user)
	..()
	if((mode == DRONE_RECHARGING) && !stat && recharging_text)
		user.text2tab("<span class='warning'>[recharging_text]</span>")
	if(stat & BROKEN)
		user.text2tab("<span class='warning'>[src] is smoking and steadily buzzing. \
			It seems to be broken.</span>")
	if(metal_cost)
		user.text2tab("<span class='notice'>It has [materials.amount(MAT_METAL)] \
			units of metal stored.</span>")
	if(glass_cost)
		user.text2tab("<span class='notice'>It has [materials.amount(MAT_GLASS)] \
			units of glass stored.</span>")

/obj/machinery/droneDispenser/power_change()
	..()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/droneDispenser/process()
	..()
	if((stat & (NOPOWER|BROKEN)) || !anchored)
		return

	if(!materials.has_materials(using_materials))
		return // We require more minerals

	// We are currently in the middle of something
	if(timer > world.time)
		return

	switch(mode)
		if(DRONE_READY)
			// If we have X drone shells already on our turf
			if(maximum_idle && (count_shells() >= maximum_idle))
				return // then do nothing; check again next tick
			if(begin_create_message)
				visible_message("<span class='notice'>\
					[src] [begin_create_message]</span>")
			if(work_sound)
				playsound(src, work_sound, 50, 1)
			mode = DRONE_PRODUCTION
			timer = world.time + production_time
			update_icon()

		if(DRONE_PRODUCTION)
			materials.use_amount(using_materials)
			if(power_used)
				use_power(power_used)

			new dispense_type(loc)

			if(create_sound)
				playsound(src, create_sound, 50, 1)
			if(end_create_message)
				visible_message("<span class='notice'>[src] \
					[end_create_message]</span>")

			mode = DRONE_RECHARGING
			timer = world.time + cooldownTime
			update_icon()

		if(DRONE_RECHARGING)
			if(recharge_sound)
				playsound(src, recharge_sound, 50, 1)
			if(recharge_message)
				visible_message("<span class='notice'>\
					[src] [recharge_message]</span>")

			mode = DRONE_READY
			update_icon()

/obj/machinery/droneDispenser/proc/count_shells()
	. = 0
	for(var/a in loc)
		if(istype(a, dispense_type))
			.++

/obj/machinery/droneDispenser/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = icon_off
	else if(mode == DRONE_RECHARGING)
		icon_state = icon_recharging
	else if(mode == DRONE_PRODUCTION)
		icon_state = icon_creating
	else
		icon_state = icon_on

/obj/machinery/droneDispenser/attackby(obj/item/O, mob/living/user)
	if(istype(O, /obj/item/stack))
		if(!O.materials[MAT_METAL] && !O.materials[MAT_GLASS])
			return ..()
		if(!metal_cost && !glass_cost)
			user.text2tab("<span class='warning'>There isn't a place \
				to insert [O]!</span>")
			return
		var/obj/item/stack/sheets = O
		if(!user.canUnEquip(sheets))
			user.text2tab("<span class='warning'>[O] is stuck to your hand, \
				you can't get it off!</span>")
			return

		var/used = materials.insert_stack(sheets, sheets.amount)

		if(used)
			user.text2tab("<span class='notice'>You insert [used] \
				sheet[used > 1 ? "s" : ""] into [src].</span>")
		else
			user.text2tab("<span class='warning'>The [src] isn't accepting the \
				[sheets].</span>")

	else if(istype(O, /obj/item/weapon/weldingtool))
		if(!(stat & BROKEN))
			user.text2tab("<span class='warning'>[src] doesn't need repairs.</span>")
			return

		var/obj/item/weapon/weldingtool/WT = O

		if(!WT.isOn())
			return

		if(WT.get_fuel() < 1)
			user.text2tab("<span class='warning'>You need more fuel to \
				complete this task!</span>")
			return

		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		user.visible_message(
			"<span class='notice'>[user] begins patching up \
				[src] with [WT].</span>",
			"<span class='notice'>You begin restoring the \
				damage to [src]...</span>")

		if(!do_after(user, 40/O.toolspeed, target = src))
			return
		if(!src || !WT.remove_fuel(1, user))
			return

		user.visible_message(
			"<span class='notice'>[user] fixes [src]!</span>",
			"<span class='notice'>You restore [src] to operation.</span>")

		stat &= ~BROKEN
		health = max_health
		update_icon()
	else
		return ..()

/obj/machinery/droneDispenser/take_damage(damage, damage_type = BRUTE,
	sound_effect = TRUE)
	// But why would you hurt the dispenser?
	switch(damage_type)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		else
			return
	health = max(health - damage, 0)
	if(!health && !(stat & BROKEN))
		if(break_message)
			audible_message("<span class='warning'>[src] \
				[break_message]</span>")
		if(break_sound)
			playsound(src, break_sound, 50, 1)
		stat |= BROKEN
		update_icon()

#undef DRONE_PRODUCTION
#undef DRONE_RECHARGING
#undef DRONE_READY
