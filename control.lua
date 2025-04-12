local function handle(entity, player)
  
  local item = prototypes.item[player.mod_settings["btrf-item"].value]

  -- end if it dont run on fuel
  if entity.ghost_prototype.void_energy_source_prototype then return end

  if entity.insert_plan and not player.mod_settings["btrf-override-blueprint-fuel"].value then return end

  -- make sure the amount is nonzero
  if player.mod_settings["btrf-stacks"].value == 0 then return end

  -- make sure the item exists
  if not item then
    player.create_local_flying_text{
      text = { "btrf-message.error-no-item", { player.mod_settings["btrf-item"].value } },
      create_at_cursor = true
    }
    return
  end

  -- make sure the fuel category is allowed for that entity
  if (entity.ghost_prototype.burner_prototype and not entity.ghost_prototype.burner_prototype.fuel_categories[item.fuel_category]) then
    player.create_local_flying_text{
      text = { "btrf-message.error-invalid-fuel" },
      create_at_cursor = true
    }
    return
  end

  -- calculate maximum possible stacks
  local max_stacks = entity.ghost_prototype.burner_prototype.fuel_inventory_size
  local stacks = player.mod_settings["btrf-stacks"].value

  local actual_stacks = max_stacks >= stacks and stacks or max_stacks

  local inventories = {} -- math to spread out multiple stacks
  for i=0,math.floor(actual_stacks) do
    inventories[i+1] = {
      inventory = defines.inventory.fuel,
      stack = i,
      count = (actual_stacks - i) >= 1 and item.stack_size or (actual_stacks - i) * item.stack_size
    }
  end

  -- create the request
  entity.insert_plan = {{
    id = { name = item.name },
    items = { in_inventory = inventories }
  }}
end

script.on_event(defines.events.on_built_entity, function (event)
  handle(event.entity, game.players[event.player_index])
end, {{filter = "ghost_type", type = "locomotive"}})