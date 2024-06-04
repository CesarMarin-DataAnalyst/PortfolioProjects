SELECT * FROM DATACLEANING
GO

-----CONVERT DATA FORMAT FOR THE SALEDATE COLUMN TO REMOVE THE TIMESTAMP AND LEAVING ONLY 
-----THE DATE (YYYY-MM-DD)


ALTER TABLE datacleaning
ALTER COLUMN SaleDate DATE
GO

---Populate Property Address data

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,ISNULL (a.propertyaddress, b.propertyaddress)
FROM datacleaning a
INNER JOIN datacleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--where a.propertyaddress is null
GO


UPDATE a
SET propertyaddress = ISNULL (a.propertyaddress, b.propertyaddress)
FROM datacleaning a
INNER JOIN datacleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null
GO


---Breaking out Address into individual columns (Address, City, State)
---Starting with the PropertyAddress


SELECT PropertyAddress
FROM DataCleaning

SELECT PropertyAddress, SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))
FROM DataCleaning


ALTER TABLE datacleaning
ADD PropSplitAddress NVARCHAR (255) 
GO

UPDATE datacleaning
SET PropSplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
GO

ALTER TABLE datacleaning
ADD PropSplitCity NVARCHAR (255) 
GO

UPDATE datacleaning
SET PropSplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))
GO

--Using PARSENAME for getting the Owner's individual Address, City and State

SELECT PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2) as City 
, PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1) as State
FROM DataCleaning

ALTER TABLE datacleaning
ADD OwnerSplitAddress NVARCHAR (255) 
GO

UPDATE datacleaning
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)
GO

ALTER TABLE datacleaning
ADD OwnerSplitCity NVARCHAR (255) 
GO

UPDATE datacleaning
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
GO

ALTER TABLE datacleaning
ADD OwnerSplitState NVARCHAR (255) 
GO

UPDATE datacleaning
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
GO

---Change Y and N to Yes and No in SoldAsVacant column using the CASE statement

SELECT SoldAsVacant, count (*)
FROM DataCleaning
GROUP BY SoldAsVacant
order by 2
GO


SELECT SoldAsVacant, 
CASE
WHEN SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant 
End
FROM DataCleaning
GO

UPDATE DataCleaning
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant 
End
GO

--Remove Duplicates


WITH RowNumCTE AS (
SELECT *
, ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
			   propertyaddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
					UniqueID
  ) row_num
FROM DataCleaning
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress


--- Delete unused columns

Select * from DataCleaning

ALTER TABLE datacleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress




