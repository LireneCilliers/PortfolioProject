SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing

-- Standardise date format
ALTER TABLE NashvilleHousing
    ADD SaleDateConverted Date;

UPDATE NashvilleHousing
    SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data
SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing
    --WHERE PropertyAddress is null
    ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
    FROM PortfolioProject.dbo.NashvilleHousing a
    JOIN PortfolioProject.dbo.NashvilleHousing b
	    ON a.ParcelID = b.ParcelID
	    AND a.[UniqueID ] <> b.[UniqueID ]
    WHERE a.PropertyAddress is null

UPDATE a
    SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
    From PortfolioProject.dbo.NashvilleHousing a
    JOIN PortfolioProject.dbo.NashvilleHousing b
	    ON a.ParcelID = b.ParcelID
	    AND a.[UniqueID ] <> b.[UniqueID ]
    WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
    FROM PortfolioProject.dbo.NashvilleHousing
    --WHERE PropertyAddress is null
    --ORDER by ParcelID

SELECT
    CASE
        WHEN CHARINDEX(',', PropertyAddress) > 0
        THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
        ELSE PropertyAddress
    END AS Address1,
    CASE
        WHEN CHARINDEX(',', PropertyAddress) > 0
        THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
        ELSE ''
    END AS Address2
    FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
    ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
    SET PropertySplitAddress = 
        CASE
            WHEN CHARINDEX(',', PropertyAddress) > 0
            THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
            ELSE PropertyAddress
        END;

ALTER TABLE NashvilleHousing
    ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
    SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
    FROM PortfolioProject.dbo.NashvilleHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
    FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
    ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
    SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
    ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
    SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
    ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
    SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
    FROM PortfolioProject.dbo.NashvilleHousing
    GROUP BY SoldAsVacant
    ORDER BY 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
    FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
    SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates
;
WITH RowNumCTE AS(
    SELECT *,
	    ROW_NUMBER() OVER (
	    PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

    FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
    FROM RowNumCTE
    WHERE row_num > 1
    ORDER BY PropertyAddress

SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing

-- Delete Unused Columns
SELECT *
    FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
