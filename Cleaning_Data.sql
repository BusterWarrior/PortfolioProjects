/*

Cleaning Data in SQL Queries

Skills Used: CONVERT, JOINS, SET, SUBSTRING, PARSENAME, CASE, PARTITION BY, CTE, TEMP TABLE 
*/

SELECT*
FROM Portfolio_Project.dbo.NashvilleHousing


-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




 --------------------------------------------------------------------------------------------------------------------------



-- Populate Property Address data

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
order by ParcelID


SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing x
JOIN Portfolio_Project.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is NULL


-- Update Empty Property Address data

UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)

FROM Portfolio_Project.dbo.NashvilleHousing x
JOIN Portfolio_Project.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
	WHERE x.PropertyAddress is NULL
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *

FROM Portfolio_Project.dbo.NashvilleHousing


-- Alternative Way to Breakdown Into Individual Columns

SELECT OwnerAddress

FROM Portfolio_Project.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
FROM Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio_Project.dbo.NashvilleHousing

UPdate NashvilleHousing
SET SoldAsVacant = CASE WHEN 
SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio_Project.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH ROW_NUM_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) Row_Num

FROM Portfolio_Project.dbo.NashvilleHousing

)

SELECT *
FROM ROW_NUM_CTE
WHERE Row_Num >1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















