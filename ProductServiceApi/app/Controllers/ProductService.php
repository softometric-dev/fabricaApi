<?php

namespace App\Controllers;
use CodeIgniter\Controller;
Use App\Helpers\common_helper;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\ProductService_model;
use App\Controllers\BaseController;

use App\Models\DataModels\Responses\CreateProductRequestDataModel;
use App\Models\DataModels\Requests\CreateProductResponseDataModel;
use App\Models\DataModels\Responses\GetProductRequestDataModel;
use App\Models\DataModels\Requests\GetProductResponseDataModel;
use App\Models\DataModels\Responses\UpdateProductRequestDataModel;
use App\Models\DataModels\Requests\UpdateProductResponseDataModel;
use App\Models\DataModels\Responses\DeleteProductRequestDataModel;
use App\Models\DataModels\Requests\DeleteProductResponseDataModel;
use App\Models\DataModels\Responses\SearchProductRequestDataModel;
use App\Models\DataModels\Requests\SearchProductResponseDataModel;

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

            $createProductRequestDataModel = CreateProductRequestDataModel::fromJson($this->request->getBody());
           
            $createProductRequestDataModel->authInfo = $authInfo;
            $createProductRequestDataModel->validateAndEnrichData();
          
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

            $authInfo = $this->checkPermission();

            $getProductRequestDataModel = GetProductRequestDataModel::fromJson($this->request->getBody());

            $getProductRequestDataModel->authInfo = $authInfo;
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

            $updateProductRequestDataModel = UpdateProductRequestDataModel::fromJson($this->request->getBody());

            $updateProductRequestDataModel->authInfo = $authInfo;
            $updateProductRequestDataModel->validateAndEnrichData();

        
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
            $this->ProductService_model->deleteProductProc($deleteProductRequestDataModel, $deleteProductResponseDataModel);

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

            $authInfo = $this->checkPermission();
           
            $searchProductRequestDataModel = SearchProductRequestDataModel::fromJson($this->request->getBody());
            $searchProductRequestDataModel->authInfo = $authInfo;
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

}