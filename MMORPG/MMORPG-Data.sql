/*
MMORPG Player Data Exploration 

A look at gaming metrics to evaluate for gameplay improvement and data validation.

*/

-- How many characters are there?
SELECT
	COUNT(*)
FROM
	characters


-- How many characters are there?
-- Exclude admin and low level characters
SELECT
	COUNT(*)
FROM
	characters
WHERE
	AccessLevel = 0 AND level > 10


-- Temporary Table to only show relevant characters in future queries
CREATE TEMPORARY TABLE temp_characters AS
	SELECT *
	FROM 
		characters
	WHERE
		AccessLevel = 0 AND level > 10


-- Count records to verify results
SELECT
	COUNT(*)
FROM
	temp_characters


-- What class do most players use?
-- Building query to determine class from numerical data
SELECT 
	char_name,
	CASE
		WHEN Class = 0 OR Class = 1 THEN 'Monarch'
		WHEN Class = 61 OR Class = 48 THEN 'Knight'
		WHEN Class = 734 OR Class = 1186 THEN 'Wizard'
		WHEN Class = 138 OR Class = 37 THEN 'Elf'
		WHEN Class = 2786 OR Class = 2796 THEN 'Dark Elf'
		ELSE 'Invalid Class'
	END AS 
		characterClass
FROM 
	temp_characters
ORDER BY
	characterClass


-- Count the characters in each class
-- Using the previous CASE expression as a sub-query
SELECT
	characterClass,
	COUNT(characterClass) AS characterCount
FROM(
	SELECT 
		CASE
			WHEN Class = 0 OR Class = 1 THEN 'Monarch'
			WHEN Class = 61 OR Class = 48 THEN 'Knight'
			WHEN Class = 734 OR Class = 1186 THEN 'Wizard'
			WHEN Class = 138 OR Class = 37 THEN 'Elf'
			WHEN Class = 2786 OR Class = 2796 THEN 'Dark Elf'
			ELSE 'Invalid Class'
		END AS 
			characterClass
	FROM 
		temp_characters
	) AS classes
GROUP BY
	characterClass
ORDER BY
	characterClass


-- What percentage of characters exist in each class?
-- Add percentage column: dividing count by total characters
SELECT
	characterClass,
	COUNT(characterClass) AS characterCount,
	(COUNT(characterClass) / 253) * 100 AS percentage
FROM(
	SELECT 
		CASE
			WHEN Class = 0 OR Class = 1 THEN 'Monarch'
			WHEN Class = 61 OR Class = 48 THEN 'Knight'
			WHEN Class = 734 OR Class = 1186 THEN 'Wizard'
			WHEN Class = 138 OR Class = 37 THEN 'Elf'
			WHEN Class = 2786 OR Class = 2796 THEN 'Dark Elf'
			ELSE 'Invalid Class'
		END AS 
			characterClass
	FROM 
		temp_characters
	) AS classes	-- this alias is not used, but defining one is required
GROUP BY
	characterClass
ORDER BY
	characterClass


-- What stats do each class use?
-- Average of each stat for each class
SELECT
	-- Differentiate characters by class
	CASE
			WHEN Class = 0 OR Class = 1 THEN 'Monarch'
			WHEN Class = 61 OR Class = 48 THEN 'Knight'
			WHEN Class = 734 OR Class = 1186 THEN 'Wizard'
			WHEN Class = 138 OR Class = 37 THEN 'Elf'
			WHEN Class = 2786 OR Class = 2796 THEN 'Dark Elf'
			ELSE 'Invalid Class'
		END AS 
			characterClass,
	-- Average of each stat
	AVG(Str), AVG(Con), AVG(Dex),
	AVG(Cha), AVG(Intel), AVG(Wis)
FROM
	temp_characters
GROUP BY
	characterClass
ORDER BY
	characterClass


-- What weapon do characters use?
-- Get item name from character_items table
SELECT
	item_name,
	COUNT(*) as total
FROM 
	character_items
JOIN 
	-- Foreign Key of items table linked to character
	temp_characters ON 
	character_items.char_id = temp_characters.objid
JOIN
	-- Foreign Key of weapon table linked to character_items
	weapon ON
	character_items.item_id = weapon.item_id
WHERE
	-- Verify the item is being used (equipped)
	is_equipped = 1
GROUP BY
	item_name
ORDER BY
	total DESC


-- What enchant level of weapon do players have?
-- What weapons do players find are worth enchanting (improving) and to what degree?

-- List Items by Class and Enchant Level
SELECT 
	temp_characters.char_name,
		-- Differentiate characters by class
	CASE
			WHEN Class = 0 OR Class = 1 THEN 'Monarch'
			WHEN Class = 61 OR Class = 48 THEN 'Knight'
			WHEN Class = 734 OR Class = 1186 THEN 'Wizard'
			WHEN Class = 138 OR Class = 37 THEN 'Elf'
			WHEN Class = 2786 OR Class = 2796 THEN 'Dark Elf'
			ELSE 'Invalid Class'
		END AS 
			characterClass,
	character_items.item_name,
	character_items.enchantlvl
FROM 
	character_items
JOIN 
	-- Foreign Key of items table linked to character
	temp_characters ON 
	character_items.char_id = temp_characters.objid
WHERE 
	-- Verify the item is a weapon
	item_id IN(
		SELECT 
			item_id 
		FROM 
			weapon
	)
ORDER BY 
	characterClass,
	character_items.enchantlvl DESC


-- Do all bosses in the spawnlist exist in the monster list?
SELECT DISTINCT 
	npc_id 
FROM 
	spawnlist_boss 
WHERE 
	npc_id 
NOT IN (
	SELECT 
		npc.npcid 
	FROM 
		npc
	)


-- Are items sold in shops valid, existing items?
SELECT * 
FROM 
	shop
LEFT JOIN 
	-- Compare to etcitem table
	etcitem ON 
	shop.item_id = etcitem.item_id 
LEFT JOIN 
	-- Compare to armor table
	armor ON 
	shop.item_id = armor.item_id
LEFT JOIN 
	-- Compare to weapon table
	weapon ON 
	shop.item_id = weapon.item_id
WHERE 
	-- If NULL in all 3 places, 
	-- an invalid item is being sold in shops
	etcitem.item_id IS NULL AND
	armor.item_id IS NULL AND
	weapon.item_id IS NULL


-- How much money do characters have?
SELECT
	temp_characters.char_name,
	character_items.count AS currency
FROM
	temp_characters
INNER JOIN
	character_items ON
	temp_characters.objid = character_items.char_id
WHERE
	item_id = 40308 -- item_id for currency 
ORDER BY
	count DESC
