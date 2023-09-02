select *
from NashvilleHousing


-- Standardize Date Format

select SaleDate, convert(date,saledate)
from NashvilleHousing

alter table nashvillehousing 
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,saledate)

select SaleDateConverted
from NashvilleHousing


-- Populate Property Address data 

select *
from NashvilleHousing
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as Address,
substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address
from NashvilleHousing

alter table nashvillehousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table nashvillehousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))


select PropertySplitAddress, PropertySplitCity
from NashvilleHousing


select OwnerAddress
from NashvilleHousing

select
parsename(replace(owneraddress, ',','.'), 3),
parsename(replace(owneraddress, ',','.'), 2),
parsename(replace(owneraddress, ',','.'), 1)
from NashvilleHousing


alter table nashvillehousing 
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',','.'), 3)

alter table nashvillehousing 
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(owneraddress, ',','.'), 2)

alter table nashvillehousing 
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(owneraddress, ',','.'), 1)


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-- Remove Duplicates


with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelId,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 order by
					UniqueId
					) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from NashvilleHousing


-- Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table NashvilleHousing
drop column saledate