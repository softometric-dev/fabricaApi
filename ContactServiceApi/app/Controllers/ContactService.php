<?php

namespace App\Controllers;
use CodeIgniter\Controller;
Use App\Helpers\common_helper;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\ContactService_model;
use App\Controllers\BaseController;

use App\Models\DataModels\Requests\CreateContactFormRequestDataModel;
use App\Models\DataModels\Responses\CreateContactFormResponseDataModel;
use App\Models\DataModels\Requests\CreateDealEnquiryRequestDataModel;
use App\Models\DataModels\Responses\CreateDealEnquiryResponseDataModel;
use App\Models\DataModels\Requests\CreatePartnerRequestDataModel;
use App\Models\DataModels\Responses\CreatePartnerResponseDataModel;
use App\Models\DataModels\Requests\CreateProductEnquiryRequestDataModel;
use App\Models\DataModels\Responses\CreateProductEnquiryResponseDataModel;
use App\Models\DataModels\Requests\DeleteContactFormRequestDataModel;
use App\Models\DataModels\Responses\DeleteContactFormResponseDataModel;
use App\Models\DataModels\Requests\DeleteDealEnquiryRequestDataModel;
use App\Models\DataModels\Responses\DeleteDealEnquiryResponseDataModel;
use App\Models\DataModels\Requests\DeletePartnerRequestDataModel;
use App\Models\DataModels\Responses\DeletePartnerResponseDataModel;
use App\Models\DataModels\Requests\DeleteProductEnquiryRequestDataModel;
use App\Models\DataModels\Responses\DeleteProductEnquiryResponseDataModel;
use App\Models\DataModels\Requests\SearchContactFormRequestDataModel;
use App\Models\DataModels\Responses\SearchContactFormResponseDataModel;
use App\Models\DataModels\Requests\SearchDealEnquiryRequestDataModel;
use App\Models\DataModels\Responses\SearchDealEnquiryResponseDataModel;
use App\Models\DataModels\Requests\SearchPartnerRequestDataModel;
use App\Models\DataModels\Responses\SearchPartnerResponseDataModel;
use App\Models\DataModels\Requests\SearchProductEnquiryRequestDataModel;
use App\Models\DataModels\Responses\SearchProductEnquiryResponseDataModel;

class ContactService extends BaseController
{

     protected $ContactService_model;
    public function __construct()
    {
        $this->ContactService_model = new ContactService_model();
    }

    public function createContactForm()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $createContactFormResponseDataModel = new CreateContactFormResponseDataModel();

            // $authInfo = $this->checkPermission();

            $createContactFormRequestDataModel = CreateContactFormRequestDataModel::fromJson($this->request->getBody());

            // $createContactFormRequestDataModel->authInfo = $authInfo;
            $createContactFormRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->createContactFormProc($createContactFormRequestDataModel,$createContactFormResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($createContactFormResponseDataModel);

        }
        catch (\Exception $e) {
            $createContactFormResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createContactFormResponseDataModel, $e);
        }
    }

    public function createDealEnquiry()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $createDealEnquiryResponseDataModel = new CreateDealEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $createDealEnquiryRequestDataModel = CreateDealEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $createDealEnquiryRequestDataModel->authInfo = $authInfo;
            $createDealEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->createDealEnquiryProc($createDealEnquiryRequestDataModel,$createDealEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($createDealEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $createDealEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createDealEnquiryResponseDataModel, $e);
        }
    }

    public function createPartner()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $createPartnerResponseDataModel = new CreatePartnerResponseDataModel();

            // $authInfo = $this->checkPermission();

            $createPartnerRequestDataModel = CreatePartnerRequestDataModel::fromJson($this->request->getBody());

            // $createPartnerRequestDataModel->authInfo = $authInfo;
            $createPartnerRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->createPartnerProc($createPartnerRequestDataModel,$createPartnerResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($createPartnerResponseDataModel);

        }
        catch (\Exception $e) {
            $createPartnerResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createPartnerResponseDataModel, $e);
        }
    }

     public function createProductEnquiry()
	{
        try
		{
            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $createProductEnquiryResponseDataModel = new CreateProductEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $createProductEnquiryRequestDataModel = CreateProductEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $createProductEnquiryRequestDataModel->authInfo = $authInfo;
            $createProductEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->createProductEnquiryProc($createProductEnquiryRequestDataModel,$createProductEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($createProductEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $createProductEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createProductEnquiryResponseDataModel, $e);
        }
    }

    public function deleteContactForm()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteContactFormResponseDataModel = new DeleteContactFormResponseDataModel();

            // $authInfo = $this->checkPermission();

            $deleteContactFormRequestDataModel = DeleteContactFormRequestDataModel::fromJson($this->request->getBody());

            // $deleteContactFormRequestDataModel->authInfo = $authInfo;
            $deleteContactFormRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->deleteContactFormProc($deleteContactFormRequestDataModel,$deleteContactFormResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteContactFormResponseDataModel);

        }
        catch (\Exception $e) {
            $deleteContactFormResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteContactFormResponseDataModel, $e);
        }
    }

     public function deleteDealEnquiry()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteDealEnquiryResponseDataModel = new DeleteDealEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $deleteDealEnquiryRequestDataModel = DeleteDealEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $deleteDealEnquiryRequestDataModel->authInfo = $authInfo;
            $deleteDealEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->deleteDealEnquiryProc($deleteDealEnquiryRequestDataModel,$deleteDealEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteDealEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $deleteDealEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteDealEnquiryResponseDataModel, $e);
        }
    }

    public function deletePartner()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deletePartnerResponseDataModel = new DeletePartnerResponseDataModel();

            // $authInfo = $this->checkPermission();

            $deletePartnerRequestDataModel = DeletePartnerRequestDataModel::fromJson($this->request->getBody());

            // $deletePartnerRequestDataModel->authInfo = $authInfo;
            $deletePartnerRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->deletePartnerProc($deletePartnerRequestDataModel,$deletePartnerResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deletePartnerResponseDataModel);

        }
        catch (\Exception $e) {
            $deletePartnerResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deletePartnerResponseDataModel, $e);
        }
    }


    public function deleteProductEnquiry()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteProductEnquiryResponseDataModel = new DeleteProductEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $deleteProductEnquiryRequestDataModel = DeleteProductEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $deleteProductEnquiryRequestDataModel->authInfo = $authInfo;
            $deleteProductEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->deleteProductEnquiryProc($deleteProductEnquiryRequestDataModel,$deleteProductEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteProductEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $deleteProductEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteProductEnquiryResponseDataModel, $e);
        }
    }


    public function searchContactForm()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchContactFormResponseDataModel = new SearchContactFormResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchContactFormRequestDataModel = SearchContactFormRequestDataModel::fromJson($this->request->getBody());

            // $searchContactFormRequestDataModel->authInfo = $authInfo;
            $searchContactFormRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->searchContactFormProc($searchContactFormRequestDataModel,$searchContactFormResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchContactFormResponseDataModel);

        }
        catch (\Exception $e) {
            $searchContactFormResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchContactFormResponseDataModel, $e);
        }
    }

    public function searchDealEnquiry()
	{
        try
		{


            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchDealEnquiryResponseDataModel = new SearchDealEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchDealEnquiryRequestDataModel = SearchDealEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $searchDealEnquiryRequestDataModel->authInfo = $authInfo;
            $searchDealEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->searchDealEnquiryProc($searchDealEnquiryRequestDataModel,$searchDealEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchDealEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $searchDealEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchDealEnquiryResponseDataModel, $e);
        }
    }

     public function searchPartner()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchPartnerResponseDataModel = new SearchPartnerResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchPartnerRequestDataModel = SearchPartnerRequestDataModel::fromJson($this->request->getBody());

            // $searchPartnerRequestDataModel->authInfo = $authInfo;
            $searchPartnerRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->searchPartnerProc($searchPartnerRequestDataModel,$searchPartnerResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchPartnerResponseDataModel);

        }
        catch (\Exception $e) {
            $searchPartnerResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchPartnerResponseDataModel, $e);
        }
    }


    public function searchProductEnquiry()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchProductEnquiryResponseDataModel = new SearchProductEnquiryResponseDataModel();

            // $authInfo = $this->checkPermission();

            $searchProductEnquiryRequestDataModel = SearchProductEnquiryRequestDataModel::fromJson($this->request->getBody());

            // $searchProductEnquiryRequestDataModel->authInfo = $authInfo;
            $searchProductEnquiryRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->ContactService_model->searchProductEnquiryProc($searchProductEnquiryRequestDataModel,$searchProductEnquiryResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchProductEnquiryResponseDataModel);

        }
        catch (\Exception $e) {
            $searchProductEnquiryResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchProductEnquiryResponseDataModel, $e);
        }
    }


     

}