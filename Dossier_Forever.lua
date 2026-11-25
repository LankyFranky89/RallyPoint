-- Rally Point: the 9 new WoW Forever dungeons (compiled 2026-11-24 from community guides).
-- Quest IDs >= 9900000 are placeholders; the real ID is learned from your quest log by name.
local _, ns = ...
ns.ForeverInfo, ns.ForeverByName = {}, {}
ns.ZoneNames[99100] = "Riverglades"

ns.Dungeons[99001] = {name="Hall of Thanes", raid=false, parent=1537, locs={{1537,43.5,52.0}}, forever=true, note="Entrance: spider-webbed passage left of the High Seat (Magni)."}
tinsert(ns.Order, 99001)
ns.Quests[96390] = {n="Nip 'Em in the Bud", r=10, l=18, d={99001}, s={{k=1, n="Earthseer Farsen", z=1, x=64.8, y=58.5, f="A"}}, fv=true}
ns.ForeverInfo[96390] = {nt="Kill 10 Dark Iron Spies (~76.7, 60.7). A spy drops the Dark Iron Map.", rw=nil, vf=true, un=false, fac="A", real=true}
ns.ForeverByName["Nip 'Em in the Bud"] = ns.ForeverByName["Nip 'Em in the Bud"] or {}; tinsert(ns.ForeverByName["Nip 'Em in the Bud"], 96390)
ns.Quests[9900001] = {n="Old Ironforge Incursion", r=9, l=16, d={99001}, s={{k=3, n="Earthseer Farsen", dd={99001}, f="A"}}, ps={96390}, fv=true}
ns.ForeverInfo[9900001] = {nt="Loot Durgen Dirgehammer's Head (final boss). Turn in to King Magni.", rw={"Calibrated Blunderbuss","Ironforge Greathammer","Deepblaze"}, vf=true, un=true, fac="A", real=false}
ns.ForeverByName["Old Ironforge Incursion"] = ns.ForeverByName["Old Ironforge Incursion"] or {}; tinsert(ns.ForeverByName["Old Ironforge Incursion"], 9900001)
ns.Quests[96403] = {n="Important Heirlooms", r=10, l=15, d={99001}, s={{k=1, n="Thom Filch", z=1537, x=32.6, y=44.6, f="A"}}, fv=true}
ns.ForeverInfo[96403] = {nt="Collect 8 Dwarven Heirlooms inside.", rw={"Dwarven Tome","Tomb Robber's Gloves"}, vf=false, un=false, fac="A", real=true}
ns.ForeverByName["Important Heirlooms"] = ns.ForeverByName["Important Heirlooms"] or {}; tinsert(ns.ForeverByName["Important Heirlooms"], 96403)
ns.Quests[96394] = {n="The Restless Dead", r=10, l=15, d={99001}, s={{k=1, n="Afadra Dunwall (inside)", f="A"}}, fv=true}
ns.ForeverInfo[96394] = {nt="Kill 15 Enraged Apparitions and 10 Tormented Souls.", rw={"Dusty Belt","Cryptwalker Bracers"}, vf=false, un=false, fac="A", real=true}
ns.ForeverByName["The Restless Dead"] = ns.ForeverByName["The Restless Dead"] or {}; tinsert(ns.ForeverByName["The Restless Dead"], 96394)
ns.Quests[96395] = {n="An Ancient Grudge", r=10, l=15, d={99001}, s={{k=1, n="Ghostly Attendant (inside)"}}, fv=true}
ns.ForeverInfo[96395] = {nt="Kill Faldrim Anvilmar (first boss).", rw={"Catacomb Cloak","Deepgrave Trousers"}, vf=false, un=false, fac="B", real=true}
ns.ForeverByName["An Ancient Grudge"] = ns.ForeverByName["An Ancient Grudge"] or {}; tinsert(ns.ForeverByName["An Ancient Grudge"], 96395)
ns.Quests[98423] = {n="The Treaty of Understanding", r=9, l=16, d={99001}, s={{k=2, n="Treaty of Understanding (vault, final room)"}}, fv=true}
ns.ForeverInfo[98423] = {nt="Deliver the tablet to King Magni Bronzebeard.", rw=nil, vf=true, un=false, fac="B", real=true}
ns.ForeverByName["The Treaty of Understanding"] = ns.ForeverByName["The Treaty of Understanding"] or {}; tinsert(ns.ForeverByName["The Treaty of Understanding"], 98423)

ns.Dungeons[99002] = {name="Ruins of Lordaeron", raid=false, parent=85, locs={{85,72.4,11.6}}, forever=true, note="Through the front gate, left before the keep, up the stairs."}
tinsert(ns.Order, 99002)
ns.Quests[9900002] = {n="Light's Justice", r=12, l=22, d={99002}, s={{k=1, n="Morbin Lightbane", z=1497, x=57.8, y=89.7, f="H"}}, fv=true}
ns.ForeverInfo[9900002] = {nt="Collect 25 Intact Limbs.", rw={"The Stitcher","Spare Part Bindings"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Light's Justice"] = ns.ForeverByName["Light's Justice"] or {}; tinsert(ns.ForeverByName["Light's Justice"], 9900002)
ns.Quests[9900003] = {n="The New Plague", r=12, l=22, d={99002}, s={{k=1, n="Theodore Griffs", z=1497, x=46.7, y=71.9, f="H"}}, fv=true}
ns.ForeverInfo[9900003] = {nt="Bring back the Highly Toxic Strain.", rw={"Plaguefang","Blight Gloves"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The New Plague"] = ns.ForeverByName["The New Plague"] or {}; tinsert(ns.ForeverByName["The New Plague"], 9900003)
ns.Quests[9900004] = {n="The Wrath of Rath'mael", r=12, l=22, d={99002}, s={{k=1, n="Deathguard Kristof", z=85, x=65.2, y=60.1, f="H"}}, fv=true}
ns.ForeverInfo[9900004] = {nt="Kill Rath'mael.", rw={"Forsaken Greataxe","Gnarled Necromancer's Staff"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Wrath of Rath'mael"] = ns.ForeverByName["The Wrath of Rath'mael"] or {}; tinsert(ns.ForeverByName["The Wrath of Rath'mael"], 9900004)
ns.Quests[9900005] = {n="A Frightened Request", r=12, l=22, d={99002}, s={{k=1, n="Tabetha Heartweaver", z=130, x=44.6, y=42.9, f="H"}}, fv=true}
ns.ForeverInfo[9900005] = {nt="Find out what happened to Edward Heartweaver.", rw={"Edward's Knife","Tabitha's Cuffs"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["A Frightened Request"] = ns.ForeverByName["A Frightened Request"] or {}; tinsert(ns.ForeverByName["A Frightened Request"], 9900005)
ns.Quests[9900006] = {n="Unending Torment", r=12, l=21, d={99002}, s={{k=3, n="Abominable Head (drops from The Baron)", dd={99002}, f="H"}}, fv=true}
ns.ForeverInfo[9900006] = {nt="Bring the head to Master Apothecary Faranell. Starts a 5-step chain.", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Unending Torment"] = ns.ForeverByName["Unending Torment"] or {}; tinsert(ns.ForeverByName["Unending Torment"], 9900006)
ns.Quests[9900007] = {n="Abominable Creatures", r=12, l=21, d={99002}, s={{k=1, n="Captain Truman (inside)", f="A"}}, fv=true}
ns.ForeverInfo[9900007] = {nt="Bring the Head of the Baron.", rw={"Monstrous Cleaver","Grave Shroud","Slain Baron's Signet"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Abominable Creatures"] = ns.ForeverByName["Abominable Creatures"] or {}; tinsert(ns.ForeverByName["Abominable Creatures"], 9900007)
ns.Quests[9900008] = {n="Bloodied Insignia", r=12, l=22, d={99002}, s={{k=3, n="Bloodied Insignia (undead drop)", dd={99002}, f="A"}}, fv=true}
ns.ForeverInfo[9900008] = {nt="Collect 10 Bloodied Insignia for General Marcus Jonathan (Stormwind).", rw={"Duty Bound Leggings","Remembrance Armor"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Bloodied Insignia"] = ns.ForeverByName["Bloodied Insignia"] or {}; tinsert(ns.ForeverByName["Bloodied Insignia"], 9900008)
ns.Quests[9900009] = {n="Remember That I Love You", r=12, l=22, d={99002}, s={{k=2, n="Crumpled Paper (Rath'mael's graveyard)", f="A"}}, fv=true}
ns.ForeverInfo[9900009] = {nt="Bring the Blood-Stained Letter to Orphan Matron Nightingale. Starts a 2-step chain.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Remember That I Love You"] = ns.ForeverByName["Remember That I Love You"] or {}; tinsert(ns.ForeverByName["Remember That I Love You"], 9900009)
ns.Quests[9900010] = {n="Crest of Lordaeron", r=12, l=22, d={99002}, s={{k=3, n="Crest of Lordaeron (random spot inside)", dd={99002}}}, fv=true}
ns.ForeverInfo[9900010] = {nt="Alliance: Lady Dena Kennedy (Stormwind). Horde: Oran Snakewrithe (Undercity).", rw={"Small Sack of Gems"}, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["Crest of Lordaeron"] = ns.ForeverByName["Crest of Lordaeron"] or {}; tinsert(ns.ForeverByName["Crest of Lordaeron"], 9900010)

ns.Dungeons[99003] = {name="Excavation Site: Wetlands", raid=false, parent=11, locs={{11,48.1,56.5}}, forever=true, note="Meeting stone path starts ~53.9, 65.4, up the winding path left of Thelgen Rock."}
tinsert(ns.Order, 99003)
ns.Quests[9900011] = {n="Songblade Search", r=21, l=31, d={99003}, s={{k=1, n="Dorin Songblade", z=44, x=25.6, y=46.6, f="A"}}, fv=true}
ns.ForeverInfo[9900011] = {nt="Look for Daewyn Songblade at the excavation. Leads to Fallen in the Fen.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Songblade Search"] = ns.ForeverByName["Songblade Search"] or {}; tinsert(ns.ForeverByName["Songblade Search"], 9900011)
ns.Quests[9900012] = {n="Fallen in the Fen", r=21, l=31, d={99003}, s={{k=1, n="Dorin Songblade", z=44, x=25.6, y=46.6, f="A"}}, ps={9900011}, fv=true}
ns.ForeverInfo[9900012] = {nt="", rw={"Daewyn's Girdle","Songblade Stabilizer"}, vf=true, un=false, fac="A", real=false}
ns.ForeverByName["Fallen in the Fen"] = ns.ForeverByName["Fallen in the Fen"] or {}; tinsert(ns.ForeverByName["Fallen in the Fen"], 9900012)
ns.Quests[9900013] = {n="Lost in the Thicket Things", r=21, l=31, d={99003}, s={{k=1, n="Caitlin Grassman", z=11, x=11.9, y=58.8, f="A"}}, fv=true}
ns.ForeverInfo[9900013] = {nt="Find out what happened to Ardin Grassman. Leads to Heartwoven.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Lost in the Thicket Things"] = ns.ForeverByName["Lost in the Thicket Things"] or {}; tinsert(ns.ForeverByName["Lost in the Thicket Things"], 9900013)
ns.Quests[9900014] = {n="Heartwoven", r=21, l=31, d={99003}, s={{k=3, n="Reed-woven Heart (item)", dd={99003}, f="A"}}, ps={9900013}, fv=true}
ns.ForeverInfo[9900014] = {nt="Bring the Reed-woven Heart to Caitlin Grassman.", rw={"Greater Healing Potion x4","Mana Potion x4"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Heartwoven"] = ns.ForeverByName["Heartwoven"] or {}; tinsert(ns.ForeverByName["Heartwoven"], 9900014)
ns.Quests[9900015] = {n="Highland Hides", r=21, l=28, d={99003}, s={{k=1, n="James Halloran", z=11, x=8.6, y=55.7, f="A"}}, fv=true}
ns.ForeverInfo[9900015] = {nt="Collect 4 Thicket Raptor Hides. First do: Young Crocolisk Skins", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Highland Hides"] = ns.ForeverByName["Highland Hides"] or {}; tinsert(ns.ForeverByName["Highland Hides"], 9900015)
ns.Quests[9900016] = {n="Horrors in the Highland", r=21, l=31, d={99003}, s={{k=1, n="Rethiel the Greenwarden", z=11, x=56.3, y=40.3, f="A"}}, fv=true}
ns.ForeverInfo[9900016] = {nt="Bring the Horrible Rootcore. First do: Tramping Paws, Fire Taboo, Blisters on the Land Chain starts with: Tramping Paws", rw={"Ironwood Destroyer","Curl of Life","Hornbeam Heft"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Horrors in the Highland"] = ns.ForeverByName["Horrors in the Highland"] or {}; tinsert(ns.ForeverByName["Horrors in the Highland"], 9900016)
ns.Quests[9900017] = {n="Lost Relic Carry", r=21, l=31, d={99003}, s={{k=3, n="Titan Relic (Relic Guardian drop)", dd={99003}, f="A"}}, fv=true}
ns.ForeverInfo[9900017] = {nt="Take the relic to Prospector Whelgar, then High Explorer Magellas (Prehistoric Prism).", rw={"Explorer's League Dustcover","Healer's Staff","Heavehammer"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Lost Relic Carry"] = ns.ForeverByName["Lost Relic Carry"] or {}; tinsert(ns.ForeverByName["Lost Relic Carry"], 9900017)
ns.Quests[9900018] = {n="Changing Tastes", r=21, l=31, d={99003}, s={{k=1, n="Borstan", z=1637, x=57.3, y=53.3, f="H"}}, fv=true}
ns.ForeverInfo[9900018] = {nt="Collect 4 Thicket Raptor Meat.", rw={"Satchel of Potions","Serrated Raptor Claw"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Changing Tastes"] = ns.ForeverByName["Changing Tastes"] or {}; tinsert(ns.ForeverByName["Changing Tastes"], 9900018)
ns.Quests[9900019] = {n="Dragonmaw Rumors", r=21, l=31, d={99003}, s={{k=1, n="Zaruk", z=45, x=74.4, y=35.6, f="H"}}, fv=true}
ns.ForeverInfo[9900019] = {nt="Meet the Deathstalker Agent above the Dragonmaw camp.", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Dragonmaw Rumors"] = ns.ForeverByName["Dragonmaw Rumors"] or {}; tinsert(ns.ForeverByName["Dragonmaw Rumors"], 9900019)
ns.Quests[9900020] = {n="Open the Maw", r=21, l=31, d={99003}, s={{k=1, n="Deathstalker Agent", z=11, x=51.4, y=59.2, f="H"}}, ps={9900019}, fv=true}
ns.ForeverInfo[9900020] = {nt="Kill 2 Dragonmaw Saboteurs and 4 Warders, and get the Dragonmaw Dispatch.", rw={"Knife-Polishing Rag","Dirt-Heavy Bracers"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Open the Maw"] = ns.ForeverByName["Open the Maw"] or {}; tinsert(ns.ForeverByName["Open the Maw"], 9900020)
ns.Quests[9900021] = {n="Elder Knowledge", r=21, l=31, d={99003}, s={{k=3, n="Titan Relic (Relic Guardian drop)", dd={99003}, f="H"}}, fv=true}
ns.ForeverInfo[9900021] = {nt="Take the relic to Elder Rise, then Muln Earthfury (Earthen Echo).", rw={"Heavehammer","Healer's Staff","Furs of the Earthen Ring"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Elder Knowledge"] = ns.ForeverByName["Elder Knowledge"] or {}; tinsert(ns.ForeverByName["Elder Knowledge"], 9900021)

ns.Dungeons[99004] = {name="City of Dalaran", raid=false, parent=36, locs={{130,68.5,45.1}}, forever=true, note="Needs the Dalaran Sewer Key (from Image of Archmage Modera). Lyn the Ignored needs the Tome of Dalaran (Black Tome from Shadowfang Keep)."}
tinsert(ns.Order, 99004)
ns.Quests[92432] = {n="An Alarming Request", r=30, l=33, d={99004}, s={{k=1, n="Emissary Jacques", z=267, x=48.3, y=60.1, f="A"}}, fv=true}
ns.ForeverInfo[92432] = {nt="Go to the Image of Archmage Modera by the sewer entrance.", rw=nil, vf=false, un=true, fac="A", real=true}
ns.ForeverByName["An Alarming Request"] = ns.ForeverByName["An Alarming Request"] or {}; tinsert(ns.ForeverByName["An Alarming Request"], 92432)
ns.Quests[92458] = {n="Heart of Disruption", r=25, l=33, d={99004}, s={{k=1, n="Image of Archmage Modera", z=130, x=68.5, y=45.1, f="A"}}, ps={92432}, fv=true}
ns.ForeverInfo[92458] = {nt="Get an Arcane Mote from the Shade of the Archmage (final boss). Modera also gives the Sewer Key.", rw=nil, vf=false, un=true, fac="A", real=true}
ns.ForeverByName["Heart of Disruption"] = ns.ForeverByName["Heart of Disruption"] or {}; tinsert(ns.ForeverByName["Heart of Disruption"], 92458)
ns.Quests[9900022] = {n="Friend of the Kirin Tor", r=25, l=33, d={99004}, s={{k=1, n="Image of Archmage Modera", z=130, x=68.5, y=45.1, f="A"}}, ps={92458}, fv=true}
ns.ForeverInfo[9900022] = {nt="Deliver the Arcane Mote to Archmage Celindra, Violet Citadel.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Friend of the Kirin Tor"] = ns.ForeverByName["Friend of the Kirin Tor"] or {}; tinsert(ns.ForeverByName["Friend of the Kirin Tor"], 9900022)
ns.Quests[9900023] = {n="Starving Arcane", r=25, l=33, d={99004}, s={{k=1, n="Image of Archmage Modera", z=130, x=68.5, y=45.1, f="A"}}, ps={92432}, fv=true}
ns.ForeverInfo[9900023] = {nt="Kill 8 Seeking Remnants, 8 Saturated Remnants and 8 Mana Echoes.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Starving Arcane"] = ns.ForeverByName["Starving Arcane"] or {}; tinsert(ns.ForeverByName["Starving Arcane"], 9900023)
ns.Quests[9900024] = {n="Power Overwhelming", r=25, l=33, d={99004}, s={{k=1, n="High Sorcerer Andromath", z=1519, x=48.9, y=87.7, f="A"}}, fv=true}
ns.ForeverInfo[9900024] = {nt="Kill the Arcanic Enigma.", rw={"Violet Sash","Runebound Gloves"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Power Overwhelming"] = ns.ForeverByName["Power Overwhelming"] or {}; tinsert(ns.ForeverByName["Power Overwhelming"], 9900024)
ns.Quests[9900025] = {n="A Green Sample", r=25, l=33, d={99004}, s={{k=1, n="Shylamiir", z=1519, x=31.4, y=63.0, f="A"}}, fv=true}
ns.ForeverInfo[9900025] = {nt="Get a Fel Infused Blossom in Runeweaver Square (Fell Ancient).", rw={"Vine Pruner's Cloak","Thorn Protecting Girdle"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["A Green Sample"] = ns.ForeverByName["A Green Sample"] or {}; tinsert(ns.ForeverByName["A Green Sample"], 9900025)
ns.Quests[9900026] = {n="Prison Break In", r=30, l=34, d={99004}, s={{k=1, n="Magus Wordeen Voidglare", z=267, x=61.5, y=20.9, f="H"}}, fv=true}
ns.ForeverInfo[9900026] = {nt="Collect the Bloodstone Wedge, Marble, Shard and Oval at Lordamere Internment Camp.", rw=nil, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Prison Break In"] = ns.ForeverByName["Prison Break In"] or {}; tinsert(ns.ForeverByName["Prison Break In"], 9900026)
ns.Quests[9900027] = {n="Key to the City", r=30, l=33, d={99004}, s={{k=1, n="Magus Wordeen Voidglare", z=267, x=61.5, y=20.9, f="H"}}, fv=true}
ns.ForeverInfo[9900027] = {nt="Get the Grimy Key from the Warden's Footlocker (Kegan Darkmar's house). Chain starts with: Prison Break In", rw=nil, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Key to the City"] = ns.ForeverByName["Key to the City"] or {}; tinsert(ns.ForeverByName["Key to the City"], 9900027)
ns.Quests[9900028] = {n="Dalaran Patrols", r=25, l=35, d={99004}, s={{k=1, n="Magus Wordeen Voidglare", z=267, x=61.5, y=20.9, f="H"}}, ps={9900026,9900027}, fv=true}
ns.ForeverInfo[9900028] = {nt="Kill 6 Dalaran Summoners and 8 Elemental Slaves (Alterac ~26.0, 61.8).", rw=nil, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Dalaran Patrols"] = ns.ForeverByName["Dalaran Patrols"] or {}; tinsert(ns.ForeverByName["Dalaran Patrols"], 9900028)
ns.Quests[9900029] = {n="Blood in the Streets", r=25, l=33, d={99004}, s={{k=1, n="Magus Wordeen Voidglare", z=267, x=61.5, y=20.9, f="H"}}, ps={9900028}, fv=true}
ns.ForeverInfo[9900029] = {nt="Find the Image of Archmage Modera at the sewer entrance.", rw=nil, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Blood in the Streets"] = ns.ForeverByName["Blood in the Streets"] or {}; tinsert(ns.ForeverByName["Blood in the Streets"], 9900029)
ns.Quests[9900030] = {n="Heart of Disruption", r=25, l=33, d={99004}, s={{k=1, n="Image of Archmage Modera", z=130, x=68.5, y=45.1, f="H"}}, ps={9900029}, fv=true}
ns.ForeverInfo[9900030] = {nt="Get an Arcane Mote from the Shade of the Archmage. Bring it to Magus Wordeen (then Shrewd Negotiations).", rw=nil, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Heart of Disruption"] = ns.ForeverByName["Heart of Disruption"] or {}; tinsert(ns.ForeverByName["Heart of Disruption"], 9900030)
ns.Quests[9900031] = {n="Source of Power", r=25, l=33, d={99004}, s={{k=1, n="Doctor Martin Felben", z=1497, x=46.4, y=74.3, f="H"}}, fv=true}
ns.ForeverInfo[9900031] = {nt="Collect 6 Cracked Sentry Cores.", rw={"Unstable Power Core","Construct Cloak"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Source of Power"] = ns.ForeverByName["Source of Power"] or {}; tinsert(ns.ForeverByName["Source of Power"], 9900031)
ns.Quests[9900032] = {n="The Grave Knight", r=25, l=33, d={99004}, s={{k=1, n="Melisara", z=267, x=62.6, y=20.6, f="H"}}, fv=true}
ns.ForeverInfo[9900032] = {nt="Defeat Atrexis the Grave Knight.", rw={"Gravewalker Boots","Undead Knight's Bracers"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Grave Knight"] = ns.ForeverByName["The Grave Knight"] or {}; tinsert(ns.ForeverByName["The Grave Knight"], 9900032)
ns.Quests[9900033] = {n="Opportunistic Education", r=25, l=33, d={99004}, s={{k=1, n="Rexxie Copperclutch (inside)", f="H"}}, fv=true}
ns.ForeverInfo[9900033] = {nt="Find The Founding of Dalaran in the Atrium of Fortune.", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Opportunistic Education"] = ns.ForeverByName["Opportunistic Education"] or {}; tinsert(ns.ForeverByName["Opportunistic Education"], 9900033)

ns.Dungeons[99005] = {name="The Drowned City", raid=false, parent=33, locs={{33,21.4,27.9}}, forever=true, note="Underwater. Swim past the Vile Reef to the Sunken Hollow (large tablet by the cave)."}
tinsert(ns.Order, 99005)
ns.Quests[95789] = {n="Shady Saltseers", r=34, l=40, d={99005}, s={{k=1, n="Krazek", z=33, x=27.0, y=77.2}}, fv=true}
ns.ForeverInfo[95789] = {nt="Collect 10 Voodoo-Infused Artifacts from the Saltseer pirates.", rw={"Rusted Troll War Belt","Saltseer's Helm"}, vf=true, un=false, fac="B", real=true}
ns.ForeverByName["Shady Saltseers"] = ns.ForeverByName["Shady Saltseers"] or {}; tinsert(ns.ForeverByName["Shady Saltseers"], 95789)
ns.Quests[95791] = {n="The Saltseer Captain", r=34, l=40, d={99005}, s={{k=1, n="Krazek", z=33, x=27.0, y=77.2}}, fv=true}
ns.ForeverInfo[95791] = {nt="Kill Captain Dreadrise and 3 Saltseer Coroners.", rw={"Mutinous Cuffs","South Seas Shroud"}, vf=false, un=false, fac="B", real=true}
ns.ForeverByName["The Saltseer Captain"] = ns.ForeverByName["The Saltseer Captain"] or {}; tinsert(ns.ForeverByName["The Saltseer Captain"], 95791)
ns.Quests[9900034] = {n="The Vile Reef", r=30, l=37, d={99005}, s={{k=1, n="Kin'weelay", z=33, x=32.3, y=27.7, f="H"}}, fv=true}
ns.ForeverInfo[9900034] = {nt="Recover a Tablet Shard from Gri'lek's tablet (~25, 23).", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Vile Reef"] = ns.ForeverByName["The Vile Reef"] or {}; tinsert(ns.ForeverByName["The Vile Reef"], 9900034)
ns.Quests[9900035] = {n="The Gurubashi Legends of Old", r=32, l=40, d={99005}, s={{k=1, n="Kin'weelay", z=33, x=32.3, y=27.7, f="H"}}, ps={9900034}, fv=true}
ns.ForeverInfo[9900035] = {nt="", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Gurubashi Legends of Old"] = ns.ForeverByName["The Gurubashi Legends of Old"] or {}; tinsert(ns.ForeverByName["The Gurubashi Legends of Old"], 9900035)
ns.Quests[9900036] = {n="Locating the Lost City", r=32, l=40, d={99005}, s={{k=1, n="Kin'weelay", z=33, x=32.3, y=27.7, f="H"}}, ps={9900035}, fv=true}
ns.ForeverInfo[9900036] = {nt="", rw=nil, vf=true, un=false, fac="H", real=false}
ns.ForeverByName["Locating the Lost City"] = ns.ForeverByName["Locating the Lost City"] or {}; tinsert(ns.ForeverByName["Locating the Lost City"], 9900036)
ns.Quests[95775] = {n="The Drowned City", r=32, l=40, d={99005}, s={{k=1, n="Kin'weelay", z=33, x=32.3, y=27.7, f="H"}}, ps={9900036}, fv=true}
ns.ForeverInfo[95775] = {nt="Make rubbings of the four tablets inside.", rw=nil, vf=true, un=false, fac="H", real=true}
ns.ForeverByName["The Drowned City"] = ns.ForeverByName["The Drowned City"] or {}; tinsert(ns.ForeverByName["The Drowned City"], 95775)
ns.Quests[9900037] = {n="Enemies in the Water", r=32, l=37, d={99005}, s={{k=1, n="Grom'gol Base Camp", z=33, x=32.3, y=27.7, f="H"}}, fv=true}
ns.ForeverInfo[9900037] = {nt="Collect 10 Brinescale Tridents near the entrance.", rw=nil, vf=true, un=false, fac="H", real=false}
ns.ForeverByName["Enemies in the Water"] = ns.ForeverByName["Enemies in the Water"] or {}; tinsert(ns.ForeverByName["Enemies in the Water"], 9900037)
ns.Quests[95776] = {n="The Only Good Brinescale...", r=32, l=38, d={99005}, s={{k=1, n="Grom'gol Base Camp", z=33, x=32.3, y=27.7, f="H"}}, ps={9900037}, fv=true}
ns.ForeverInfo[95776] = {nt="Kill Var'Taka.", rw={"Tidesoaked Leggings","Naga Priestess's Mantle"}, vf=true, un=false, fac="H", real=true}
ns.ForeverByName["The Only Good Brinescale..."] = ns.ForeverByName["The Only Good Brinescale..."] or {}; tinsert(ns.ForeverByName["The Only Good Brinescale..."], 95776)
ns.Quests[96774] = {n="Ancient Gurubashi Idol", r=32, l=40, d={99005}, s={{k=1, n="Mazu'kon", z=215, f="H"}}, fv=true}
ns.ForeverInfo[96774] = {nt="Bring an Ancient Gurubashi Idol (Primeval Elemental).", rw=nil, vf=false, un=false, fac="H", real=true}
ns.ForeverByName["Ancient Gurubashi Idol"] = ns.ForeverByName["Ancient Gurubashi Idol"] or {}; tinsert(ns.ForeverByName["Ancient Gurubashi Idol"], 96774)
ns.Quests[9900038] = {n="An Acquaintance in Southshore", r=32, l=40, d={99005}, s={{k=1, n="Brother Nimetz", z=33, f="A"}}, fv=true}
ns.ForeverInfo[9900038] = {nt="Bring the Savage Coast Report Bundle to Loremaster Dibbs (Southshore).", rw=nil, vf=true, un=false, fac="A", real=false}
ns.ForeverByName["An Acquaintance in Southshore"] = ns.ForeverByName["An Acquaintance in Southshore"] or {}; tinsert(ns.ForeverByName["An Acquaintance in Southshore"], 9900038)
ns.Quests[95787] = {n="Take Two With Water", r=32, l=40, d={99005}, s={{k=1, n="Loremaster Dibbs", z=267, f="A"}}, ps={9900038}, fv=true}
ns.ForeverInfo[95787] = {nt="Make rubbings of the four I'lalai tablets. Follow-up: Findings for the Explorer's League.", rw={"Ancient Voodoo Pouch","Intrepid Explorer's Chainmail"}, vf=false, un=false, fac="A", real=true}
ns.ForeverByName["Take Two With Water"] = ns.ForeverByName["Take Two With Water"] or {}; tinsert(ns.ForeverByName["Take Two With Water"], 95787)
ns.Quests[95788] = {n="Magics of the Drowned City", r=32, l=40, d={99005}, s={{k=1, n="Loremaster Dibbs", z=267, f="A"}}, fv=true}
ns.ForeverInfo[95788] = {nt="Collect 5 I'lalai Fetishes. Follow-up: The Web of Magic.", rw={"Rune-Etched Epaulets","Apprentice Sorcerer's Slacks"}, vf=false, un=false, fac="A", real=true}
ns.ForeverByName["Magics of the Drowned City"] = ns.ForeverByName["Magics of the Drowned City"] or {}; tinsert(ns.ForeverByName["Magics of the Drowned City"], 95788)
ns.Quests[97130] = {n="Ancient Gurubashi Secrets", r=34, l=40, d={99005}, s={{k=1, n="Archmage Timear", z=36, x=15.4, y=74.0, f="A"}}, fv=true}
ns.ForeverInfo[97130] = {nt="Bring an Ancient Gurubashi Idol.", rw=nil, vf=false, un=false, fac="A", real=true}
ns.ForeverByName["Ancient Gurubashi Secrets"] = ns.ForeverByName["Ancient Gurubashi Secrets"] or {}; tinsert(ns.ForeverByName["Ancient Gurubashi Secrets"], 97130)

ns.Dungeons[99006] = {name="Krol'dok Stronghold", raid=false, parent=99100, locs={{99100,37.5,37.5}}, forever=true, note="Cave west of the fortress gates. Krol'dok Compound Key (Moulding + 12 Iron Bar + 4 Thick Leather) opens the upper area."}
tinsert(ns.Order, 99006)
ns.Quests[9900039] = {n="Krol'dok Moulding", r=37, l=45, d={99006}, s={{k=1, n="Kreza Darkthorn", z=99100, x=59.8, y=46.0, f="H"}}, fv=true}
ns.ForeverInfo[9900039] = {nt="Loot the Moulding (Tunk), then Key Ingredients: 12 Iron Bar + 4 Thick Leather.", rw={"Krol'dok Compound Key"}, vf=false, un=true, fac="H", real=false}
ns.ForeverByName["Krol'dok Moulding"] = ns.ForeverByName["Krol'dok Moulding"] or {}; tinsert(ns.ForeverByName["Krol'dok Moulding"], 9900039)
ns.Quests[9900040] = {n="Krol'dok Moulding", r=37, l=45, d={99006}, s={{k=1, n="Alphonse Dumas", z=99100, x=64.4, y=82.0, f="A"}}, fv=true}
ns.ForeverInfo[9900040] = {nt="Loot the Moulding (Tunk), then Key Ingredients: 12 Iron Bar + 4 Thick Leather.", rw={"Krol'dok Compound Key"}, vf=false, un=true, fac="A", real=false}
ns.ForeverByName["Krol'dok Moulding"] = ns.ForeverByName["Krol'dok Moulding"] or {}; tinsert(ns.ForeverByName["Krol'dok Moulding"], 9900040)
ns.Quests[9900041] = {n="Eye of Mugg", r=40, l=45, d={99006}, s={{k=1, n="Krom'rosh", z=99100, x=59.4, y=45.5, f="H"}}, fv=true}
ns.ForeverInfo[9900041] = {nt="Kill Overlord Mugg. First do: Clugfist's Decree, The Wayward Warrior Chain starts with: Clugfist's Decree", rw={"Rock on Stick","Bigger Rock on Bigger Stick","Stick No Rock"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Eye of Mugg"] = ns.ForeverByName["Eye of Mugg"] or {}; tinsert(ns.ForeverByName["Eye of Mugg"], 9900041)
ns.Quests[9900042] = {n="Tome of Twilight", r=39, l=44, d={99006}, s={{k=1, n="Tran'gul", z=99100, x=59.5, y=44.0, f="H"}}, fv=true}
ns.ForeverInfo[9900042] = {nt="Bring the Tome of Twilight (Nar'gurk).", rw={"Indoctrinated Choker","Convert's Bindings"}, vf=true, un=false, fac="H", real=false}
ns.ForeverByName["Tome of Twilight"] = ns.ForeverByName["Tome of Twilight"] or {}; tinsert(ns.ForeverByName["Tome of Twilight"], 9900042)
ns.Quests[9900043] = {n="A Token of Vengeance", r=38, l=42, d={99006}, s={{k=1, n="Da'grosh", z=99100, x=33.4, y=38.0, f="H"}}, fv=true}
ns.ForeverInfo[9900043] = {nt="Collect 15 Cultist Ears. First do: Bring Me His Head", rw={"Semblance of Twilight"}, vf=true, un=false, fac="H", real=false}
ns.ForeverByName["A Token of Vengeance"] = ns.ForeverByName["A Token of Vengeance"] or {}; tinsert(ns.ForeverByName["A Token of Vengeance"], 9900043)
ns.Quests[9900044] = {n="Eye of Mugg", r=40, l=45, d={99006}, s={{k=1, n="Commander Demar Brant", z=99100, x=66.6, y=80.9, f="A"}}, fv=true}
ns.ForeverInfo[9900044] = {nt="Kill Overlord Mugg.", rw={"Rock on Stick","Bigger Rock on Bigger Stick","Stick No Rock"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Eye of Mugg"] = ns.ForeverByName["Eye of Mugg"] or {}; tinsert(ns.ForeverByName["Eye of Mugg"], 9900044)
ns.Quests[9900045] = {n="Tome of Twilight", r=39, l=44, d={99006}, s={{k=1, n="Ashe Amberhall", z=99100, x=66.6, y=81.0, f="A"}}, fv=true}
ns.ForeverInfo[9900045] = {nt="Bring the Tome of Twilight (Nar'gurk). First do: Scraps of Knowledge, Curious Trinkets, A Small Favor Chain starts with: Scraps of Knowledge", rw={"Twilight Initiate's Belt","Torn Cultist Cloak"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Tome of Twilight"] = ns.ForeverByName["Tome of Twilight"] or {}; tinsert(ns.ForeverByName["Tome of Twilight"], 9900045)
ns.Quests[9900046] = {n="Twilight Mementos", r=38, l=42, d={99006}, s={{k=1, n="Sergeant Riftan", z=99100, x=30.5, y=48.9, f="A"}}, fv=true}
ns.ForeverInfo[9900046] = {nt="Collect 8 Twilight Bangles. Follow-ups: Lingering Essence and Curios of Curiosity (blue Curio-Adorned Necklace). First do: Bring Me His Head", rw=nil, vf=true, un=false, fac="A", real=false}
ns.ForeverByName["Twilight Mementos"] = ns.ForeverByName["Twilight Mementos"] or {}; tinsert(ns.ForeverByName["Twilight Mementos"], 9900046)
ns.Quests[9900047] = {n="Vengeance of the Highborne", r=37, l=45, d={99006}, s={{k=1, n="Ranath Nightstride", z=36, x=17.5, y=66.1, f="A"}}, fv=true}
ns.ForeverInfo[9900047] = {nt="Kill Zalfan Moonshadow (patrols near Nar'gurk).", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Vengeance of the Highborne"] = ns.ForeverByName["Vengeance of the Highborne"] or {}; tinsert(ns.ForeverByName["Vengeance of the Highborne"], 9900047)

ns.Dungeons[99007] = {name="Alcaz Prison", raid=false, parent=15, locs={{15,75.3,14.1}}, forever=true, note="Basement of the big tower on Alcaz Island. Take the hill path left from the dock."}
tinsert(ns.Order, 99007)
ns.Quests[9900048] = {n="The Missing Kor'kron", r=48, l=53, d={99007}, s={{k=1, n="Eitrigg", z=1637, x=34.4, y=38.6, f="H"}}, fv=true}
ns.ForeverInfo[9900048] = {nt="Report to Nazeer Bloodpike, Brackenwall Village.", rw=nil, vf=true, un=false, fac="H", real=false}
ns.ForeverByName["The Missing Kor'kron"] = ns.ForeverByName["The Missing Kor'kron"] or {}; tinsert(ns.ForeverByName["The Missing Kor'kron"], 9900048)
ns.Quests[9900049] = {n="No Orc Left Behind", r=45, l=53, d={99007}, s={{k=1, n="Sergeant Ulka", z=15, x=70.3, y=19.0, f="H"}}, ps={9900048}, fv=true}
ns.ForeverInfo[9900049] = {nt="Find Commander Folkar inside.", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["No Orc Left Behind"] = ns.ForeverByName["No Orc Left Behind"] or {}; tinsert(ns.ForeverByName["No Orc Left Behind"], 9900049)
ns.Quests[9900050] = {n="The Honor of the Kor'kron", r=45, l=53, d={99007}, s={{k=1, n="Commander Folkar (inside)", f="H"}}, ps={9900049}, fv=true}
ns.ForeverInfo[9900050] = {nt="Search for King Varian Wrynn (Perfumed Note after Blazeroar).", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Honor of the Kor'kron"] = ns.ForeverByName["The Honor of the Kor'kron"] or {}; tinsert(ns.ForeverByName["The Honor of the Kor'kron"], 9900050)
ns.Quests[9900051] = {n="Bad News for Folkar", r=45, l=53, d={99007}, s={{k=2, n="Perfumed Note", f="H"}}, ps={9900050}, fv=true}
ns.ForeverInfo[9900051] = {nt="", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Bad News for Folkar"] = ns.ForeverByName["Bad News for Folkar"] or {}; tinsert(ns.ForeverByName["Bad News for Folkar"], 9900051)
ns.Quests[9900052] = {n="Thrall Needs to Know", r=45, l=53, d={99007}, s={{k=1, n="Commander Folkar (inside)", f="H"}}, ps={9900051}, fv=true}
ns.ForeverInfo[9900052] = {nt="Bring word to Thrall, Orgrimmar.", rw={"Fatebound Buckler","Courier's Clasp","Dustwallow Dirk"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Thrall Needs to Know"] = ns.ForeverByName["Thrall Needs to Know"] or {}; tinsert(ns.ForeverByName["Thrall Needs to Know"], 9900052)
ns.Quests[9900053] = {n="Blood Red Bandanas", r=45, l=53, d={99007}, s={{k=1, n="Sergeant Ulka", z=15, x=70.3, y=19.0, f="H"}}, fv=true}
ns.ForeverInfo[9900053] = {nt="Collect 8 Blood Red Bandanas from the Defias guards.", rw={"Bloodsplattered Bandana","Makeshift Belt"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Blood Red Bandanas"] = ns.ForeverByName["Blood Red Bandanas"] or {}; tinsert(ns.ForeverByName["Blood Red Bandanas"], 9900053)
ns.Quests[9900054] = {n="A Little Payback", r=45, l=53, d={99007}, s={{k=1, n="Sergeant Ulka", z=15, x=70.3, y=19.0, f="H"}}, fv=true}
ns.ForeverInfo[9900054] = {nt="Kill Strashaz naga and get Ca'zass's Head (Tidemistress Ca'zass).", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["A Little Payback"] = ns.ForeverByName["A Little Payback"] or {}; tinsert(ns.ForeverByName["A Little Payback"], 9900054)
ns.Quests[9900055] = {n="A Bit of Wet Work", r=45, l=53, d={99007}, s={{k=1, n="Sully McCleary", z=15, x=63.4, y=42.6, f="A"}}, fv=true}
ns.ForeverInfo[9900055] = {nt="Kill Strashaz naga and get Ca'zass's Head. First do: Our Man in Theramore Chain starts with: Our Man in Theramore", rw=nil, vf=true, un=false, fac="A", real=false}
ns.ForeverByName["A Bit of Wet Work"] = ns.ForeverByName["A Bit of Wet Work"] or {}; tinsert(ns.ForeverByName["A Bit of Wet Work"], 9900055)
ns.Quests[9900056] = {n="The Secret Prison", r=45, l=53, d={99007}, s={{k=1, n="Sully McCleary", z=15, x=63.4, y=42.6, f="A"}}, fv=true}
ns.ForeverInfo[9900056] = {nt="Find the note near Zarla Ober/Blazeroar. First do: Our Man in Theramore Chain starts with: Our Man in Theramore", rw=nil, vf=true, un=false, fac="A", real=false}
ns.ForeverByName["The Secret Prison"] = ns.ForeverByName["The Secret Prison"] or {}; tinsert(ns.ForeverByName["The Secret Prison"], 9900056)
ns.Quests[9900057] = {n="The Dragon's Journal", r=46, l=53, d={99007}, s={{k=1, n="Archmage Lan'dalock", z=36, x=15.5, y=73.4, f="A"}}, fv=true}
ns.ForeverInfo[9900057] = {nt="Bring back Zarla's Journal (Blazeroar).", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["The Dragon's Journal"] = ns.ForeverByName["The Dragon's Journal"] or {}; tinsert(ns.ForeverByName["The Dragon's Journal"], 9900057)
ns.Quests[9900058] = {n="The Man in the Iron Chains", r=45, l=53, d={99007}, s={{k=1, n="Mason Connery (inside)"}}, fv=true}
ns.ForeverInfo[9900058] = {nt="Kill The Questioner and bring the Ornate Shackle Key.", rw=nil, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["The Man in the Iron Chains"] = ns.ForeverByName["The Man in the Iron Chains"] or {}; tinsert(ns.ForeverByName["The Man in the Iron Chains"], 9900058)
ns.Quests[9900059] = {n="More Valuable Than Gold", r=45, l=53, d={99007}, s={{k=1, n="Mason Connery (inside)"}}, ps={9900058}, fv=true}
ns.ForeverInfo[9900059] = {nt="Find the treasure in Westfall.", rw=nil, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["More Valuable Than Gold"] = ns.ForeverByName["More Valuable Than Gold"] or {}; tinsert(ns.ForeverByName["More Valuable Than Gold"], 9900059)

ns.Dungeons[99008] = {name="Blackmaw Hold", raid=false, parent=16, locs={{16,38.7,33.4}}, forever=true, note="Furbolg tunnel in Azshara; the portal itself is on the Winterspring map (66.6, 84.4)."}
tinsert(ns.Order, 99008)
ns.Quests[9900060] = {n="Blackmaw Reclamation", r=47, l=60, d={99008}, s={{k=1, n="Gatekeeper Rageroar", z=16, x=42.3, y=20.3}}, fv=true}
ns.ForeverInfo[9900060] = {nt="Kill Varrox Bleakhoof and bring his head. Needs Neutral with Timbermaw Hold. First do: Legashi Threat Chain starts with: Legashi Threat", rw={"Ouroboros Ring","Eagle's Head Signet","Malefactor's End","Engraved Band"}, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["Blackmaw Reclamation"] = ns.ForeverByName["Blackmaw Reclamation"] or {}; tinsert(ns.ForeverByName["Blackmaw Reclamation"], 9900060)
ns.Quests[9900061] = {n="Blackmaw Pouches", r=55, l=60, d={99008}, s={{k=1, n="Ekkal", z=16, x=42.0, y=38.9}}, fv=true}
ns.ForeverInfo[9900061] = {nt="Loot 5 pouches. Becomes a repeatable Timbermaw rep turn-in.", rw=nil, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["Blackmaw Pouches"] = ns.ForeverByName["Blackmaw Pouches"] or {}; tinsert(ns.ForeverByName["Blackmaw Pouches"], 9900061)
ns.Quests[9900062] = {n="Claws That Rend, Tusks That Gore", r=52, l=60, d={99008}, s={{k=1, n="Ogtink", z=16, x=42.4, y=42.7}}, fv=true}
ns.ForeverInfo[9900062] = {nt="Loot drops from Withermaw and Bonesnout the Unbroken.", rw={"Great Bear Claw","Staff of Wild Beasts","Wild Malleus"}, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["Claws That Rend, Tusks That Gore"] = ns.ForeverByName["Claws That Rend, Tusks That Gore"] or {}; tinsert(ns.ForeverByName["Claws That Rend, Tusks That Gore"], 9900062)
ns.Quests[9900063] = {n="A Lost Memento", r=47, l=60, d={99008}, s={{k=3, n="Feathered Charm Necklace (satyr drop)", dd={99008}}}, fv=true}
ns.ForeverInfo[9900063] = {nt="Bring the necklace to Un'ell (Azshara).", rw={"Nama's Cherished Necklace"}, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["A Lost Memento"] = ns.ForeverByName["A Lost Memento"] or {}; tinsert(ns.ForeverByName["A Lost Memento"], 9900063)
ns.Quests[9900064] = {n="Feeding Time", r=52, l=60, d={99008}, s={{k=1, n="Flesh-Eating Lasher (inside)"}}, fv=true}
ns.ForeverInfo[9900064] = {nt="Repeatable. Random herbs, chance at the Wilted Lashling pet.", rw=nil, vf=false, un=false, fac="B", real=false}
ns.ForeverByName["Feeding Time"] = ns.ForeverByName["Feeding Time"] or {}; tinsert(ns.ForeverByName["Feeding Time"], 9900064)
ns.Quests[9900065] = {n="The Twin Bears", r=47, l=60, d={99008}, s={{k=1, n="Lorekeeper Nok", z=16}}, fv=true}
ns.ForeverInfo[9900065] = {nt="Find the Totem of Ursoc and Totem of Ursol. Needs Neutral with Timbermaw.", rw={"Guidance of Ursoc","Wisdom of Ursol"}, vf=true, un=false, fac="B", real=false}
ns.ForeverByName["The Twin Bears"] = ns.ForeverByName["The Twin Bears"] or {}; tinsert(ns.ForeverByName["The Twin Bears"], 9900065)
ns.Quests[9900066] = {n="Blackmaw Magic", r=52, l=60, d={99008}, s={{k=1, n="Muln Earthfury", z=215, x=33.4, y=22.5, f="H"}}, fv=true}
ns.ForeverInfo[9900066] = {nt="Kill Elder Shaman Bloodmane for the Blackmaw Ritual Totem.", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Blackmaw Magic"] = ns.ForeverByName["Blackmaw Magic"] or {}; tinsert(ns.ForeverByName["Blackmaw Magic"], 9900066)
ns.Quests[9900067] = {n="Blackmaw Magic", r=52, l=60, d={99008}, s={{k=1, n="Archmage Timear", z=36, x=15.4, y=74.0, f="A"}}, fv=true}
ns.ForeverInfo[9900067] = {nt="Kill Elder Shaman Bloodmane for the Blackmaw Ritual Totem.", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Blackmaw Magic"] = ns.ForeverByName["Blackmaw Magic"] or {}; tinsert(ns.ForeverByName["Blackmaw Magic"], 9900067)
ns.Quests[9900068] = {n="Get to the Roots of It", r=45, l=60, d={99008}, s={{k=1, n="Nara Wildmane", z=1638, x=75.8, y=31.2, f="H"}}, fv=true}
ns.ForeverInfo[9900068] = {nt="Collect 10 Nordrassil Root Caps. Breadcrumb from Jediga (Valormok, Azshara). First do: Beneath Nordrassil Chain starts with: Beneath Nordrassil", rw=nil, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Get to the Roots of It"] = ns.ForeverByName["Get to the Roots of It"] or {}; tinsert(ns.ForeverByName["Get to the Roots of It"], 9900068)
ns.Quests[9900069] = {n="Get to the Roots of It", r=45, l=60, d={99008}, s={{k=1, n="Mathrengyl Bearwalker", z=1657, x=35.2, y=8.2, f="A"}}, fv=true}
ns.ForeverInfo[9900069] = {nt="Collect 10 Nordrassil Root Caps. Breadcrumb from Commander Truesong (Azshara). First do: Beneath Nordrassil Chain starts with: Beneath Nordrassil", rw=nil, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Get to the Roots of It"] = ns.ForeverByName["Get to the Roots of It"] or {}; tinsert(ns.ForeverByName["Get to the Roots of It"], 9900069)

ns.Dungeons[99009] = {name="Shaper's Terrace", raid=false, parent=490, locs={{490,48.1,6.1}}, forever=true, note="Archival Panels need 15 power crystals of one colour each: Red, Blue, Green, Yellow. Collect them around Un'Goro."}
tinsert(ns.Order, 99009)
ns.Quests[9900070] = {n="Mapping the Way Forward", r=55, l=55, d={99009}, s={{k=1, n="Curator Thorius", z=1537, x=72.6, y=14.8, f="A"}}, fv=true}
ns.ForeverInfo[9900070] = {nt="", rw={"Crystal-Infused Cleaver","Beastslayer's Trident","Faintly Glowing Orb"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Mapping the Way Forward"] = ns.ForeverByName["Mapping the Way Forward"] or {}; tinsert(ns.ForeverByName["Mapping the Way Forward"], 9900070)
ns.Quests[9900071] = {n="Panic at the Digsite", r=55, l=55, d={99009}, s={{k=1, n="Curator Thorius", z=1537, x=72.6, y=14.8, f="A"}}, fv=true}
ns.ForeverInfo[9900071] = {nt="Defeat Venomridge (south of the Achromatic Crystal).", rw={"Diemetradon Scale Spaulders","Ravasaur Hide Footpads"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Panic at the Digsite"] = ns.ForeverByName["Panic at the Digsite"] or {}; tinsert(ns.ForeverByName["Panic at the Digsite"], 9900071)
ns.Quests[9900072] = {n="Digestible Research", r=55, l=55, d={99009}, s={{k=1, n="Partially Digested Journal (inside)", f="A"}}, fv=true}
ns.ForeverInfo[9900072] = {nt="Found at an abandoned camp in the pond area below the entrance ledge.", rw={"Expeditionary Legplates","Lost Researcher's Hood"}, vf=false, un=false, fac="A", real=false}
ns.ForeverByName["Digestible Research"] = ns.ForeverByName["Digestible Research"] or {}; tinsert(ns.ForeverByName["Digestible Research"], 9900072)
ns.Quests[9900073] = {n="The Dark Crystal", r=55, l=55, d={99009}, s={{k=1, n="Master Apothecary Faranell", z=1497, x=48.4, y=68.0, f="H"}}, fv=true}
ns.ForeverInfo[9900073] = {nt="Achromatic Crystal in the central tar pits.", rw={"Crystal-Infused Cleaver","Beastslayer's Trident","Faintly Glowing Orb"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["The Dark Crystal"] = ns.ForeverByName["The Dark Crystal"] or {}; tinsert(ns.ForeverByName["The Dark Crystal"], 9900073)
ns.Quests[9900074] = {n="Essence of Seeping Slimes", r=55, l=55, d={99009}, s={{k=1, n="Chemist Fuely", z=1497, x=47.8, y=72.3, f="H"}}, fv=true}
ns.ForeverInfo[9900074] = {nt="Seeping Slime Essence from slimes around the Achromatic Crystal.", rw={"Reinforced Muck Protectors","Slime-Resistant Shroud"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Essence of Seeping Slimes"] = ns.ForeverByName["Essence of Seeping Slimes"] or {}; tinsert(ns.ForeverByName["Essence of Seeping Slimes"], 9900074)
ns.Quests[9900075] = {n="Crystalline Elements", r=55, l=55, d={99009}, s={{k=1, n="Mayena Earthseeker", z=215, x=34.8, y=22.1, f="H"}}, fv=true}
ns.ForeverInfo[9900075] = {nt="", rw={"Crystalline Pauldrons","Potent Treads"}, vf=false, un=false, fac="H", real=false}
ns.ForeverByName["Crystalline Elements"] = ns.ForeverByName["Crystalline Elements"] or {}; tinsert(ns.ForeverByName["Crystalline Elements"], 9900075)

ns.ForeverPhrases = {{"thanes", 99001}, {"hall of thanes", 99001}, {"lordaeron", 99002}, {"excavation", 99003}, {"dalaran", 99004}, {"drowned city", 99005}, {"krol'dok", 99006}, {"kroldok", 99006}, {"alcaz", 99007}, {"blackmaw", 99008}, {"shaper", 99009}}
ns.ForeverKeywords = {hot=99001, rol=99002, dala=99004, dalaran=99004, drowned=99005, kroldok=99006, alcaz=99007, blackmaw=99008, bmh=99008, shapers=99009}

-- New zones the game knows but the Questie tables don't (Riverglades): find their map at login
function ns.ForeverResolveZones()
    if ns.AreaToUiMap[99100] or not (C_Map and C_Map.GetMapChildrenInfo) then return end
    for _, cont in ipairs({1415, 1414, 947}) do
        for _, m in ipairs(C_Map.GetMapChildrenInfo(cont, nil, true) or {}) do
            if m.name == "Riverglades" then ns.AreaToUiMap[99100] = m.mapID; return end
        end
    end
end

-- Placeholder IDs -> real quest IDs, learned from the quest log by title
function ns.ForeverRealID(id)
    if id < 9900000 then return id end
    local db = DungeonDossierDB and DungeonDossierDB.foreverIDs
    return db and db[id]
end

function ns.ForeverMatchLog(questLog)
    local fac = (UnitFactionGroup("player") == "Horde") and "H" or "A"
    DungeonDossierDB = DungeonDossierDB or {}
    DungeonDossierDB.foreverIDs = DungeonDossierDB.foreverIDs or {}
    local found = {}
    for id, e in pairs(questLog) do
        local list = e.title and ns.ForeverByName[e.title]
        if list then found[#found + 1] = e end
    end
    for _, e in ipairs(found) do
        for _, fid in ipairs(ns.ForeverByName[e.title]) do
            local info = ns.ForeverInfo[fid]
            if info.fac == "B" or info.fac == fac then
                e.forever = true
                questLog[fid] = e
                if fid >= 9900000 and e.id then DungeonDossierDB.foreverIDs[fid] = e.id end
            end
        end
    end
end
