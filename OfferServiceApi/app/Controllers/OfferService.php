<?php

namespace App\Controllers;
use CodeIgniter\Controller;
Use App\Helpers\common_helper;
use App\Libraries\{ApiCallException, AuthorisationException, CustomException, DatabaseException};
use App\Models\OfferService_model;
use App\Controllers\BaseController;

use App\Models\DataModels\Requests\CreateOfferRequestDataModel;
use App\Models\DataModels\Responses\CreateOfferResponseDataModel;
use App\Models\DataModels\Requests\GetOfferRequestDataModel;
use App\Models\DataModels\Responses\GetOfferResponseDataModel;
use App\Models\DataModels\Requests\UpdateOfferRequestDataModel;
use App\Models\DataModels\Responses\UpdateOfferResponseDataModel;
use App\Models\DataModels\Requests\DeleteOfferRequestDataModel;
use App\Models\DataModels\Responses\DeleteOfferResponseDataModel;
use App\Models\DataModels\Requests\SearchOfferRequestDataModel;
use App\Models\DataModels\Responses\SearchOfferResponseDataModel;

class OfferService extends BaseController
{

    protected $OfferService_model;
    public function __construct()
    {
        $this->OfferService_model = new OfferService_model();
    }

     public function createOffer()
	{
        try
		{

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $createOfferResponseDataModel = new CreateOfferResponseDataModel();
            $authInfo = $this->checkPermission();

            $requestBody = $this->request->getPost('data');
            $createOfferRequestDataModel = CreateOfferRequestDataModel::fromJson($requestBody);

            $createOfferRequestDataModel->authInfo = $authInfo;
            $createOfferRequestDataModel->validateAndEnrichData();

                        // Handle file upload
            $imageFile = $this->request->getFile('image');
            if ($imageFile && $imageFile->isValid()) {
                $relativePath = uploadImage($imageFile, 'offer');
                $createOfferRequestDataModel->newOffer->image = $relativePath;
            }
          
            set_error_handler([DatabaseException::class, 'exceptionHandler']);
            $this->OfferService_model->createOfferProc($createOfferRequestDataModel,$createOfferResponseDataModel);

            set_error_handler([CustomException::class, 'exceptionHandler']);
            $this->sendSuccessResponse($createOfferResponseDataModel);

        }
        catch (\Exception $e) {
           
            $createOfferResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($createOfferResponseDataModel, $e);
        }
    }

     public function getOffer()
	{
        try
		{

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $getOfferResponseDataModel = new GetOfferResponseDataModel();

            // $authInfo = $this->checkPermission();

            $getOfferRequestDataMode = GetOfferRequestDataModel::fromJson($this->request->getBody());

            // $getOfferRequestDataMode->authInfo = $authInfo;
            $getOfferRequestDataMode->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->OfferService_model->getOfferProc($getOfferRequestDataMode,$getOfferResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($getOfferResponseDataModel);

        }
        catch (\Exception $e) {
            $getOfferResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($getOfferResponseDataModel, $e);
        }
    }

     public function updateOffer()
    {
        try {


            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $updateOfferResponseDataModel = new UpdateOfferResponseDataModel();

            $authInfo = $this->checkPermission();


             $requestBody = $this->request->getPost('data');
             $updateOfferRequestDataModel = UpdateOfferRequestDataModel::fromJson($requestBody);


            $updateOfferRequestDataModel->authInfo = $authInfo;
            $updateOfferRequestDataModel->validateAndEnrichData();

            $offer = $updateOfferRequestDataModel->offer;

            $oldOffer = $this->OfferService_model->getOfferByIdProc($offer->offerId);

            $oldImagePath = $oldOffer && !empty($oldOffer->image) ? $oldOffer->image : null;


            // Handle new file upload
            $file = $this->request->getFile('image');
 
            if ($file && $file->isValid()) {

                if (!empty($oldImagePath)) {
                    deleteFile($oldImagePath);
                }

                $uploadedPath = uploadImage($file, 'offer');
                $offer->image = $uploadedPath;
            } 


        
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->OfferService_model->updatOfferProc($updateOfferRequestDataModel, $updateOfferResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($updateOfferResponseDataModel);

        } catch (\Exception $e) {
            $updateOfferResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($updateOfferResponseDataModel, $e);
        }
    }

     public function deleteOffer()
    {
        try {

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $deleteOfferResponseDataModel = new DeleteOfferResponseDataModel();
            
            $authInfo = $this->checkPermission();

            $deleteOfferRequestDataModel = DeleteOfferRequestDataModel::fromJson($this->request->getBody());
            $deleteOfferRequestDataModel->authInfo = $authInfo;
            $deleteOfferRequestDataModel->validateAndEnrichData();

            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $offer = $deleteOfferRequestDataModel->offerToDelete;
            $oldOffer = $this->OfferService_model->getOfferByIdProc($offer->offerId);

            $oldImagePath = $oldOffer && !empty($oldOffer->image) ? $oldOffer->image : null;

            $this->OfferService_model->deleteOfferProc($deleteOfferRequestDataModel, $deleteOfferResponseDataModel);

            if (!empty($oldImagePath)) {
              deleteFile($oldImagePath);
            }

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($deleteOfferResponseDataModel);

        } catch (\Exception $e) {
            $deleteOfferResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($deleteOfferResponseDataModel, $e);
        }
    }

     public function searchOffer()
    {
        try {
          


            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $searchOfferResponseDataModel = new SearchOfferResponseDataModel();

            // $authInfo = $this->checkPermission();
           
            $searchOfferRequestDataModel = SearchOfferRequestDataModel::fromJson($this->request->getBody());
            // $searchOfferRequestDataModel->authInfo = $authInfo;
            $searchOfferRequestDataModel->validateAndEnrichData();
         
            set_error_handler(['App\Libraries\DatabaseException', 'exceptionHandler']);
            $this->OfferService_model->searchOfferProc($searchOfferRequestDataModel, $searchOfferResponseDataModel);

            set_error_handler(['App\Libraries\CustomException', 'exceptionHandler']);
            $this->sendSuccessResponse($searchOfferResponseDataModel);

        } catch (\Exception $e) {
            $searchOfferResponseDataModel->setErrorDetails($e);
            $this->sendErrorResponse($searchOfferResponseDataModel, $e);
        }
    }


}