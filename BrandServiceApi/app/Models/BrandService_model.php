<?php

namespace App\Models;
use App\Libraries\CustomExceptionHandler;
use App\Models\Common\Base_model;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use CodeIgniter\Database\Exceptions\DatabaseException;

class BrandService_model extends Base_model
{

     public function __construct()
	{	
			parent::__construct();	
	} 

    function getAllCategoryProc($getAllCategoriesRequestDataModel,&$getAllCategoriesResponseDataModel)
	{
        
        $pagination = $getAllCategoriesRequestDataModel->pagination;

        $sql = "CALL sp_getAllCategory(?, ?)";
        try {

            $query = $this->db->query($sql, [
                $pagination->currentPage,
                $pagination->pageSize
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = CategoryDataModel::fromDbResultSet($query->getResultArray());

        $getAllCategoriesResponseDataModel->categories = count($resultSet1) > 0 ? $resultSet1 : null;
      
        mysqli_next_result($this->db->connID);

        $nextResultSet = $this->db->connID->store_result();

        $resultSet2 = $nextResultSet->fetch_all(MYSQLI_ASSOC);
        $getAllCategoriesResponseDataModel->pagination = !empty($resultSet2) ? PaginationDataModel::fromDbResultSet($resultSet2) : null;

    }

     function createBrandProc($createBrandRequestDataModel,&$createBrandResponseDataModel)
	{
        
        
        $newBrand = $createBrandRequestDataModel->newBrand;
      
        $sql = "CALL sp_createBrand(?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newBrand->brandName,
                $newBrand->category->categoryId,
                $newBrand->image,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = BrandDataModel::fromDbResultSet($query1->getResultArray());
      
        $createBrandResponseDataModel->newBrand = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function getBrandPlanProc($getBrandRequestDataModel, &$getBrandResponseDataModel)
    { 
        
        $brand = $getBrandRequestDataModel->brand;

        $sql = "CALL sp_getBrandByBrandId(?)";
        try {
         $query = $this->db->query($sql, [$brand->brandId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         // Fetch the result as an array of objects or arrays
         $resultSet1 = BrandDataModel::fromDbResultSet($query->getResultArray());
         $getBrandResponseDataModel->brand = count($resultSet1) > 0 ? $resultSet1[0] : null;
        //  if ($getBrandResponseDataModel->brand != null) {
            
        //     $baseUrl = base_url(); 
       
        //      if (!empty($getBrandResponseDataModel->brand->image)) {
        //         $getBrandResponseDataModel->brand->image = $baseUrl . $getBrandResponseDataModel->brand->image;
        //     }

            
            

        //  }
       
    }

     function getBrandPlanByIdProc($brandId)
    { 
        

        $sql = "CALL sp_getBrandByBrandId(?)";
        try {
         $query = $this->db->query($sql, [$brandId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         // Fetch the result as an array of objects or arrays
         $resultSet1 = BrandDataModel::fromDbResultSet($query->getResultArray());
         $brand = count($resultSet1) > 0 ? $resultSet1[0] : null;
         return $brand;
            
            
    }


    function updatBrandProc($updateBrandRequestDataModel, &$updateBrandResponseDataModel)
    {
        

        $brand = $updateBrandRequestDataModel->brand;

        $categoryId = !isNullOrEmpty($brand) && !isNullOrEmpty($brand->category)  && !isNullOrEmpty($brand->category->categoryId) ? $brand->category->categoryId : null;
       
        $sql1 = "CALL sp_updateBrand(?,?,?,?,?)";
        try {
            $query1 = $this->db->query($sql1, [
                $brand->brandId,
                 $brand->brandModifiedDateTime,
                 $brand->brandName,
                 $brand->image,
                $categoryId,
               
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        // Free the result object
        $this->db->connID->next_result();
        $query1->freeResult();

          // Step 2: Get updated loyalty program details
          $sql2 = "CALL sp_getBrandByBrandId(?)";
          try {
            $query2 = $this->db->query($sql2, [
               $brand->brandId,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
         

         $resultSet1 = BrandDataModel::fromDbResultSet($query2->getResultArray());
       
         $updateBrandResponseDataModel->brand = count($resultSet1) > 0 ? $resultSet1[0] : null;

       

    }

     function deleteBrandProc($deleteBrandRequestDataModel, &$deleteBrandResponseDataModel)
    {
        
        $brandToDelete = $deleteBrandRequestDataModel->brandToDelete;

        $sql = "CALL sp_deleteBrandByBrandId(?)";
        try {
            $query = $this->db->query($sql, [
                $brandToDelete->brandId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = BrandDataModel::fromDbResultSet($query->getResultArray());
		$deleteBrandResponseDataModel->deletedBrand = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

    function searchBrandProc($searchBrandRequestDataModel, &$searchBrandResponseDataModel)
    {
        
        $brand = $searchBrandRequestDataModel->brand;
        $categoryId = !isNullOrEmpty($brand) && !isNullOrEmpty($brand->category)  && !isNullOrEmpty($brand->category->categoryId) ? $brand->category->categoryId : null;
        $pagination = $searchBrandRequestDataModel->pagination;
      
        $sql = "CALL sp_searchBrand(?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $brand->brandName,
                 $categoryId,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }


        $resultSet1 = $query->getResultArray();
        
        $searchBrandResponseDataModel->brands = !empty($resultSet1) ? BrandDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();
        // $resultSet2 = $nextResultSet->fetch_all(MYSQLI_ASSOC);

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchBrandResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }
}