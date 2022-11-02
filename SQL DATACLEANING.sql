/*

Cleaning Data using SQL queries 

*/

Select *
From [Cleaning SQL data].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------------------

-- Standardize Sale Date Format

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
Add SaleDateAfter date

Update[Cleaning SQL data].[dbo].[NashvilleHousing]
Set SaleDateAfter = convert(date, SaleDate)

Select SaleDateAfter
From [Cleaning SQL data].[dbo].[NashvilleHousing]



---------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
From [Cleaning SQL data].[dbo].[NashvilleHousing] a
JOIN [Cleaning SQL data].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
From [Cleaning SQL data].[dbo].[NashvilleHousing] a
JOIN [Cleaning SQL data].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID

select PropertyAddress
From [Cleaning SQL data].[dbo].[NashvilleHousing]
where PropertyAddress is null

---------------------------------------------------------------------------------------------------

-- Breaking out address into individual coloumns (Address, City, State)

Select PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) + 1), LEN(PropertyAddress)) as City
From [Cleaning SQL data].[dbo].[NashvilleHousing]

-- Adding to Table

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
Add PropertySplitAddress varchar(255)

Update[Cleaning SQL data].[dbo].[NashvilleHousing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
Add PropertySplitCity varchar(255)

Update[Cleaning SQL data].[dbo].[NashvilleHousing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress) + 1), LEN(PropertyAddress))

-- Now breaking out owners address

Select OwnerAddress,

SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress) - 1) as Address,
SUBSTRING(OwnerAddress, (CHARINDEX(',',OwnerAddress) + 1), (LEN(OwnerAddress) - (CHARINDEX(',',OwnerAddress)+4))) as City,
SUBSTRING(OwnerAddress, LEN(OwnerAddress) - 1, 2) as State

From [Cleaning SQL data].[dbo].[NashvilleHousing]

-- Adding to Table
-- Address

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress varchar(255)

UPDATE [Cleaning SQL data].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress) - 1)

-- City

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
ADD OwnerSplitCity varchar(255)

UPDATE [Cleaning SQL data].[dbo].[NashvilleHousing]
SET OwnerSplitCity = SUBSTRING(OwnerAddress, (CHARINDEX(',',OwnerAddress) + 1), (LEN(OwnerAddress) - (CHARINDEX(',',OwnerAddress)+4)))

-- State

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
ADD OwnerSplitState varchar(255)

UPDATE [Cleaning SQL data].[dbo].[NashvilleHousing]
SET OwnerSplitState = SUBSTRING(OwnerAddress, LEN(OwnerAddress) - 1, 2)

-- To View
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM [Cleaning SQL data].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No (In Sold as Vacant Field)
-- There are some fields that have Y and N instead of Yes and No, hence not consistent

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as HowMany
FROM [Cleaning SQL data].[dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by HowMany desc

Select SoldasVacant, 
	CASE
	When SoldasVacant = 'Y' then 'Yes'
	When SoldasVacant = 'N' then 'No'
	ELSE SoldasVacant
	END
FROM [Cleaning SQL data].[dbo].[NashvilleHousing]

UPDATE [Cleaning SQL data].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE
	When SoldasVacant = 'Y' then 'Yes'
	When SoldasVacant = 'N' then 'No'
	ELSE SoldasVacant
	END 

---------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 Propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID ) Rownum

From [Cleaning SQL data].[dbo].[NashvilleHousing]

)
DELETE
From RowNumCTE
Where Rownum > 1

---------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
FROM [Cleaning SQL data].[dbo].[NashvilleHousing]

ALTER TABLE [Cleaning SQL data].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

---------------------------------------------------------------------------------------------------