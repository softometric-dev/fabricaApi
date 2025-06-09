<?php

namespace App\Controllers;
use CodeIgniter\Controller;
Use App\Helpers\common_helper;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\BrandService_model;
use App\Controllers\BaseController;
use App\Models\DataModels\Requests\GetAllCategoriesRequestDataModel;
use App\Models\DataModels\Responses\GetAllCategoriesResponseDataModel;

use App\Models\DataModels\Requests\CreateBrandRequestDataModel;
use App\Models\DataModels\Responses\CreateBrandResponseDataModel;
use App\Models\DataModels\Requests\GetBrandRequestDataModel;
use App\Models\DataModels\Responses\GetBrandResponseDataModel;
use App\Models\DataModels\Requests\UpdateBrandRequestDataModel;
use App\Models\DataModels\Responses\UpdateBrandResponseDataModel;
use App\Models\DataModels\Requests\DeleteBrandRequestDataModel;
use App\Models\DataModels\Responses\DeleteBrandResponseDataModel;
use App\Models\DataModels\Requests\SearchBrandRequestDataModel;
use App\Models\DataModels\Responses\SearchBrandResponseDataModel;

class BrandService extends BaseController
{
  protected $BrandService_model;
    public function __construct()
    {
        $this->BrandService_model = new BrandService_model();
    }

    public function getAllCategory()
	{
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);

            $getAllCategoriesResponseDataModel = new GetAllCategoriesResponseDataModel();
            $authInfo = $this->checkPermission();

            $getAllCategoriesRequestDataModel = GetAllCategoriesRequestDataModel::fromJson($this->request->getBody());
            $getAllCategoriesRequestDataModel->authInfo = $authInfo;
            $getAllCategoriesRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->BrandService_model->getAllCategoryProc($getAllCategoriesRequestDataModel,$getAllCategoriesResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($getAllCategoriesResponseDataModel);
        }
        catch (\Exception $e) {
            $getAllCategoriesResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getAllCategoriesResponseDataModel, $e);
        }
    }

     public function createBrand()
	{
        try
		{

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $createBrandResponseDataModel = new CreateBrandResponseDataModel();
            $authInfo = $this->checkPermission();

            $createBrandRequestDataModel = CreateBrandRequestDataModel::fromJson($this->request->getBody());
           
            $createBrandRequestDataModel->authInfo = $authInfo;
            $createBrandRequestDataModel->validateAndEnrichData();
          
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->BrandService_model->createBrandProc($createBrandRequestDataModel,$createBrandResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($createBrandResponseDataModel);

        }
        catch (\Exception $e) {
           
            $createBrandResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createBrandResponseDataModel, $e);
        }
    }

     public function getBrand()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $getBrandResponseDataModel = new GetBrandResponseDataModel();

            $authInfo = $this->checkPermission();

            $getBrandRequestDataModel = GetBrandRequestDataModel::fromJson($this->request->getBody());

            $getBrandRequestDataModel->authInfo = $authInfo;
            $getBrandRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->BrandService_model->getBrandPlanProc($getBrandRequestDataModel,$getBrandResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($getBrandResponseDataModel);

        }
        catch (\Exception $e) {
            $getBrandResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getBrandResponseDataModel, $e);
        }
    }

     public function updateBrand()
    {
        try {


            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $updateBrandResponseDataModel = new UpdateBrandResponseDataModel();

            $authInfo = $this->checkPermission();

            $updateBrandRequestDataModel = UpdateBrandRequestDataModel::fromJson($this->request->getBody());

            $updateBrandRequestDataModel->authInfo = $authInfo;
            $updateBrandRequestDataModel->validateAndEnrichData();

        
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->BrandService_model->updatBrandProc($updateBrandRequestDataModel, $updateBrandResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($updateBrandResponseDataModel);

        } catch (\Exception $e) {
            $updateBrandResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($updateBrandResponseDataModel, $e);
        }
    }

     public function deleteBrand()
    {
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteBrandResponseDataModel = new DeleteBrandResponseDataModel();
            
            $authInfo = $this->checkPermission();

            $deleteBrandRequestDataModel = DeleteBrandRequestDataModel::fromJson($this->request->getBody());
            $deleteBrandRequestDataModel->authInfo = $authInfo;
            $deleteBrandRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->BrandService_model->deleteBrandProc($deleteBrandRequestDataModel, $deleteBrandResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteBrandResponseDataModel);

        } catch (\Exception $e) {
            $deleteBrandResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteBrandResponseDataModel, $e);
        }
    }

     public function searchBrand()
    {
        try {
          

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchBrandResponseDataModel = new SearchBrandResponseDataModel();

            $authInfo = $this->checkPermission();
           
            $searchBrandRequestDataModel = SearchBrandRequestDataModel::fromJson($this->request->getBody());
            $searchBrandRequestDataModel->authInfo = $authInfo;
            $searchBrandRequestDataModel->validateAndEnrichData();
         
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->BrandService_model->searchBrandProc($searchBrandRequestDataModel, $searchBrandResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchBrandResponseDataModel);

        } catch (\Exception $e) {
            $searchBrandResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchBrandResponseDataModel, $e);
        }
    }


}

