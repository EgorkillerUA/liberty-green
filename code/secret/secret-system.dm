var/list/laureates = list(
	"joctopus" = list(
		"Uplink" = /obj/item/device/uplink,
	),
)

/client/verb/spawn_personal_item()
	set category = "OOC"
	set name = "Spawn personal item"
	var/mob/living/carbon/human/H = usr
	if (!istype(H))
		usr << "\red Wrong mob! Must be a human!"
		return
	var/list/items = laureates[usr.ckey]
	if (!items)
		usr << "\red You do not have any awards or personal items!"
		return
	var/selected_path
	if (items.len > 1)
		var/choise = input("Select an item") as null|anything in items
		if (isnull(choise))
			return
		selected_path = items[choise]
		items -= choise
	else
		selected_path = items[items[1]]
		items.len = 0
		H.verbs -= /client/verb/spawn_personal_item
	var/obj/spawned = new selected_path(H)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = H.equip_in_one_of_slots(spawned, slots)
	if (!where)
		spawned.loc = H.loc
		usr << "\blue Your [spawned] has been spawned!"
	else
		usr << "\blue Your [spawned] has been spawned in your [where]!"