<?php

namespace App\Controllers;
use CodeIgniter\Controller;
Use App\Helpers\common_helper;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\ProductService_model;
use App\Controllers\BaseController;

use App\Models\DataModels\Requests\CreateProductRequestDataModel;
use App\Models\DataModels\Responses\CreateProductResponseDataModel;
use App\Models\DataModels\Requests\GetProductRequestDataModel;
use App\Models\DataModels\Responses\GetProductResponseDataModel;
use App\Models\DataModels\Requests\UpdateProductRequestDataModel;
use App\Models\DataModels\Responses\UpdateProductResponseDataModel;
use App\Models\DataModels\Requests\DeleteProductRequestDataModel;
use App\Models\DataModels\Responses\DeleteProductResponseDataModel;
use App\Models\DataModels\Requests\SearchProductRequestDataModel;
use App\Models\DataModels\Responses\SearchProductResponseDataModel;
use App\Models\DataModels\Requests\GetDashboardStatisticsRequestDataModel;
use App\Models\DataModels\Responses\GetDashBoardStatisticsResponseDataModel;

class ProductService extends BaseController
{
    protected $ProductService_model;
    public function __construct()
    {
        $this->ProductService_model = new ProductService_model();
    }

     public function createProduct()
	{

      
        try
		{
            set_error_handler([CustomException::class, 'exceptionHandler']);
            $createProductResponseDataModel = new CreateProductResponseDataModel();
          
            $authInfo = $this->checkPermission();
 
            // $createProductRequestDataModel = CreateProductRequestDataModel::fromJson($this->request->getBody());

            $requestBody = $this->request->getPost('data');
             
            $createProductRequestDataModel = CreateProductRequestDataModel::fromJson($requestBody);
           
            $createProductRequestDataModel->authInfo = $authInfo;
            $createProductRequestDataModel->validateAndEnrichData();

          
             $imageFile = $this->request->getFile('image');
           
            if ($imageFile && $imageFile->isValid()) {
                $relativePath = uploadImage($imageFile, 'products');
                $createProductRequestDataModel->newProduct->image = $relativePath;
            }
          
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->ProductService_model->createProductProc($createProductRequestDataModel,$createProductResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($createProductResponseDataModel);

        }
        catch (\Exception $e) {
           
            $createProductResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createProductResponseDataModel, $e);
        }
    }

     public function getProduct()
	{
        try
		{
        
            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $getProductResponseDataModel = new GetProductResponseDataModel();

            // $authInfo = $this->checkPermission();

            $getProductRequestDataModel = GetProductRequestDataModel::fromJson($this->request->getBody());

            // $getProductRequestDataModel->authInfo = $authInfo;
            $getProductRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ProductService_model->getProductProc($getProductRequestDataModel,$getProductResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($getProductResponseDataModel);

        }
        catch (\Exception $e) {
            $getProductResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getProductResponseDataModel, $e);
        }
    }

     public function updateProduct()
    {
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $updateProductResponseDataModel = new UpdateProductResponseDataModel();

            $authInfo = $this->checkPermission();

            // $updateProductRequestDataModel = UpdateProductRequestDataModel::fromJson($this->request->getBody());

            $requestBody = $this->request->getPost('data');
             $updateProductRequestDataModel = UpdateProductRequestDataModel::fromJson($requestBody);

            $updateProductRequestDataModel->authInfo = $authInfo;
            $updateProductRequestDataModel->validateAndEnrichData();

            $product = $updateProductRequestDataModel->product;
            


            $oldProduct = $this->ProductService_model->getProductByIdProc($product->productId);

       

            $oldImagePath = $oldProduct && !empty($oldProduct->image) ? $oldProduct->image : null;

            // Handle new file upload
            $file = $this->request->getFile('image');
            if ($file && $file->isValid()) {

                if (!empty($oldImagePath)) {
                    deleteFile($oldImagePath);
                }

                $uploadedPath = uploadImage($file, 'products');
                $product->image = $uploadedPath;
            } 
        
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ProductService_model->updatProductProc($updateProductRequestDataModel, $updateProductResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($updateProductResponseDataModel);

        } catch (\Exception $e) {
            $updateProductResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($updateProductResponseDataModel, $e);
        }
    }

     public function deleteProduct()
    {
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteProductResponseDataModel = new DeleteProductResponseDataModel();
            
            $authInfo = $this->checkPermission();

            $deleteProductRequestDataModel = DeleteProductRequestDataModel::fromJson($this->request->getBody());
            $deleteProductRequestDataModel->authInfo = $authInfo;
            $deleteProductRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);

            $product = $deleteProductRequestDataModel->productToDelete;
            $oldProduct = $this->ProductService_model->getProductByIdProc($product->productId);

             $oldImagePath = $oldProduct && !empty($oldProduct->image) ? $oldProduct->image : null;

            $this->ProductService_model->deleteProductProc($deleteProductRequestDataModel, $deleteProductResponseDataModel);

            if (!empty($oldImagePath)) {
              deleteFile($oldImagePath);
            }

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteProductResponseDataModel);

        } catch (\Exception $e) {
            $deleteProductResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteProductResponseDataModel, $e);
        }
    }

      public function searchProduct()
    {
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchProductResponseDataModel = new SearchProductResponseDataModel();

            // $authInfo = $this->checkPermission();
           
            $searchProductRequestDataModel = SearchProductRequestDataModel::fromJson($this->request->getBody());
            // $searchProductRequestDataModel->authInfo = $authInfo;
            $searchProductRequestDataModel->validateAndEnrichData();
         
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ProductService_model->searchProductProc($searchProductRequestDataModel, $searchProductResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchProductResponseDataModel);

        } catch (\Exception $e) {
            $searchProductResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchProductResponseDataModel, $e);
        }
    }
    public function getDashboardStatitics()
    {

        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $getDashBoardStatisticsResponseDataModel = new GetDashBoardStatisticsResponseDataModel();

            $authInfo = $this->checkPermission();
          
            $getDashboardStatisticsRequestDataModel = GetDashboardStatisticsRequestDataModel::fromJson($this->request->getBody());
            $getDashboardStatisticsRequestDataModel->authInfo = $authInfo;
       
            $getDashboardStatisticsRequestDataModel->validateAndEnrichData();
           
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ProductService_model->getDashboardStatiticsProcs($getDashboardStatisticsRequestDataModel, $getDashBoardStatisticsResponseDataModel);
        
            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($getDashBoardStatisticsResponseDataModel);

        } catch (\Exception $e) {
            // In case of error, set the error details and send error response
            $getDashBoardStatisticsResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getDashBoardStatisticsResponseDataModel, $e);
        }
    }
}