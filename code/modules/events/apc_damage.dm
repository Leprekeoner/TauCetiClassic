/datum/event/apc_damage
	var/apcSelectionRange = 25

/datum/event/apc_damage/start()
	var/obj/machinery/power/apc/A = acquire_random_apc()
	var/severity_range = rand(7,15)
	if(severity == EVENT_LEVEL_MODERATE)
		severity_range = rand(15,23)

	for(var/obj/machinery/power/apc/apc in range(severity_range,A))
		if(severity == EVENT_LEVEL_MUNDANE)
			apc.aidisabled = TRUE
			if(prob(50))
				apc.disable_random_categories()

			if(prob(50))
				apc.disable_autocharge()
			else if(prob(50))
				apc.toggle_power_use()
			else
				apc.make_short_circuit()

			apc.update()
			apc.update_icon()
			continue
		if(is_valid_apc(apc))
			apc.emagged = 1
			apc.locked = FALSE
			apc.update_icon()

/datum/event/apc_damage/proc/acquire_random_apc()
	var/list/possibleEpicentres = landmarks_list["lightsout"]
	var/list/apcs = list()

	if(!length(possibleEpicentres))
		return

	var/epicentre = pick(possibleEpicentres)
	for(var/obj/machinery/power/apc/apc in range(epicentre,apcSelectionRange))
		if(is_valid_apc(apc))
			apcs += apc
			// Greatly increase the chance for APCs in maintenance areas to be selected
			var/area/A = get_area(apc)
			if(istype(A,/area/station/maintenance))
				apcs += apc
				apcs += apc

	if(!apcs.len)
		return

	return pick(apcs)

/datum/event/apc_damage/proc/is_valid_apc(obj/machinery/power/apc/apc)
	// Type must be exactly a basic APC.
	// This generally prevents affecting APCs in critical areas (AI core, engine room, etc.) as they often use higher capacity subtypes.
	if(apc.type != /obj/machinery/power/apc)
		return 0

	var/turf/T = get_turf(apc)
	return !apc.emagged && T && (T.z in SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING)))
