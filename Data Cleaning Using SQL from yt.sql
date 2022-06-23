/*
Cleaning Data in sql Queries
*/
select saledate, convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = convert(Date, SaleDate)

-- another method
alter table NashvilleHousing
add SaleDateCenverted Date

update NashvilleHousing
SET SaleDateCenverted = convert(Date, SaleDate)

select SaleDateCenverted, convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- insert new value for a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--isnull(a.PropertyAddress, b.PropertyAddress)
-- issnull(IFthisNull, WhatWantYouChangeFor) e.g || isnull(a.PropertyAddress, 'No Address')


------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing


--
alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255)

update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

--Check
--
select *
from PortfolioProject.dbo.NashvilleHousing

--substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
--substring(whatColumn, StartIn..Word, until..) || CHARINDEX(',', PropertyAddress) is a final position is substring syntax
--CHARINDEX(wichWord, in whatColumn)
--using -1 for delete ',' at end of word


-- another method to breaking out address SUPER EASY

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


--Address
alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--City
alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--State
alter table NashvilleHousing
add OwnerSplitState Nvarchar(255)

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select *
from PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No  in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)


DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress


WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)


select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
drop column SaleDate


------------------------------------------------------------------------------------------------------------------



