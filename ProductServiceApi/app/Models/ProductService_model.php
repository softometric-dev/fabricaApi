<?php

namespace App\Models;
use App\Libraries\CustomExceptionHandler;
use App\Models\Common\Base_model;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\DashboardStatisticsDataModel;
use App\Models\Common\DataModels\DashBoardProductEnquiryGraphDataModel;
use CodeIgniter\Database\Exceptions\DatabaseException;
class ProductService_model extends Base_model
{

    public function __construct()
	{	
			parent::__construct();	
	} 


    function createProductProc($createProductRequestDataModel,&$createProductResponseDataModel)
	{
        
        
        $newProduct = $createProductRequestDataModel->newProduct;
      
        $sql = "CALL sp_createProduct(?,?,?,?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newProduct->productName,
                $newProduct->size,
                $newProduct->category->categoryId,
                $newProduct->brand->brandId,
                $newProduct->image,
                $newProduct->specification,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = ProductDataModel::fromDbResultSet($query1->getResultArray());
      
        $createProductResponseDataModel->newProduct = count($resultSet1) > 0 ? $resultSet1[0] : null;
        
    }

     function getProductProc($getProductRequestDataModel, &$getProductResponseDataModel)
    { 
        
        $product = $getProductRequestDataModel->product;

        $sql = "CALL sp_getProductById(?)";
        try {
         $query = $this->db->query($sql, [$product->productId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         // Fetch the result as an array of objects or arrays
         $resultSet1 = ProductDataModel::fromDbResultSet($query->getResultArray());
         $getProductResponseDataModel->product = count($resultSet1) > 0 ? $resultSet1[0] : null;
       
    }

    function getProductByIdProc($productId)
    { 
        

        $sql = "CALL sp_getProductById(?)";
        try {
         $query = $this->db->query($sql, [$productId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         // Fetch the result as an array of objects or arrays
         $resultSet1 = ProductDataModel::fromDbResultSet($query->getResultArray());
         $product = count($resultSet1) > 0 ? $resultSet1[0] : null;
         return $product;
            
            
    }
    

     function updatProductProc($updateProductRequestDataModel, &$updateProductResponseDataModel)
    {
       
        $product = $updateProductRequestDataModel->product;

        $categoryId = !isNullOrEmpty($product) && !isNullOrEmpty($product->category)  && !isNullOrEmpty($product->category->categoryId) ? $product->category->categoryId : null;
        $brandId = !isNullOrEmpty($product) && !isNullOrEmpty($product->brand)  && !isNullOrEmpty($product->brand->brandId) ? $product->brand->brandId : null;
       
        $sql1 = "CALL sp_updateProductByProductId(?,?,?,?,?,?,?,?)";
        try {
            $query1 = $this->db->query($sql1, [
                $product->productId,
                $product->productName,
                $product->size,
                $categoryId,
                $brandId,
                $product->image,
                $product->specification,
                $product->productModifiedDateTime,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        // Free the result object
        $this->db->connID->next_result();
        $query1->freeResult();

          // Step 2: Get updated loyalty program details
          $sql2 = "CALL sp_getProductById(?)";
          try {
            $query2 = $this->db->query($sql2, [
                  $product->productId,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
         

         $resultSet1 = ProductDataModel::fromDbResultSet($query2->getResultArray());
       
         $updateProductResponseDataModel->product = count($resultSet1) > 0 ? $resultSet1[0] : null;

    }

     function deleteProductProc($deleteProductRequestDataModel, &$deleteProductResponseDataModel)
    {
        
        $productToDelete = $deleteProductRequestDataModel->productToDelete;

        $sql = "CALL sp_deleteProductByProductId(?)";
        try {
            $query = $this->db->query($sql, [
                $productToDelete->productId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = ProductDataModel::fromDbResultSet($query->getResultArray());
		$deleteProductResponseDataModel->deletedProduct = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

    function searchProductProc($searchProductRequestDataModel, &$searchProductResponseDataModel)
    {
        
        $product = $searchProductRequestDataModel->product;
        $categoryId = !isNullOrEmpty($product) && !isNullOrEmpty($product->category)  && !isNullOrEmpty($product->category->categoryId) ? $product->category->categoryId : null;
        $brandId = !isNullOrEmpty($product) && !isNullOrEmpty($product->brand)  && !isNullOrEmpty($product->brand->brandId) ? $product->brand->brandId : null;
       
        $pagination = $searchProductRequestDataModel->pagination;
      
        $sql = "CALL sp_searchProduct(?,?,?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $product->productName,
                $product->size,
                $categoryId,
                $brandId,
                $product->specification,
                $pagination->currentPage,
                $pagination->pageSize,
                
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }


        $resultSet1 = $query->getResultArray();
        
        $searchProductResponseDataModel->products = !empty($resultSet1) ? ProductDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();
        // $resultSet2 = $nextResultSet->fetch_all(MYSQLI_ASSOC);

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchProductResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

    public function getDashboardStatiticsProcs($getDashboardStatisticsRequestDataModel, &$getDashBoardStatisticsResponseDataModel)
    {


         // Extract request data
         $dashBoardStatistic = $getDashboardStatisticsRequestDataModel->dashBoardStatistic;
         $sql = "CALL sp_getDashboardStatistics()";
         try {
             $query = $this->db->query($sql, [
             ]);
         } catch (DatabaseException $e) {
             $this->checkDBError();
         }
     
         // Process the result set for statistics
         $resultSet1 = DashboardStatisticsDataModel::fromDbResultSet($query->getResult());
         $getDashBoardStatisticsResponseDataModel->statitics = count($resultSet1) > 0 ? $resultSet1[0] : null;

         $this->db->connID->next_result();
         $query->freeResult();
 
           // Step 2: Get updated loyalty program details
           $sql2 = "CALL sp_getDashboardProductEnquiryGraph()";
           try {
             $query2 = $this->db->query($sql2, [
             ]);
         } catch (DatabaseException $e) {
             $this->checkDBError();
         }

         $resultSet2 = DashBoardProductEnquiryGraphDataModel::fromDbResultSet($query2->getResultArray());
       
         $getDashBoardStatisticsResponseDataModel->productEnquiryGraph = count($resultSet2) > 0 ? $resultSet2 : null;


    }
}