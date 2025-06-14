<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;
use App\Libraries\{ParameterException};

class DeleteContactFormRequestDataModel extends ApiRequestDataModel
{

    public $contactFormToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $contactFormToDelete = $this->contactFormToDelete;

        // Validate mandatory inputs
        if (empty($contactFormToDelete) || empty($contactFormToDelete->contactId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'contactId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteContactFormRequestDataModel = new DeleteContactFormRequestDataModel();

        if ($jsonData !== null) {
            $contactFormToDelete = $jsonData->contactFormToDelete ?? null;
            if ($contactFormToDelete !== null) {
                $contactFormDataModel = ContactFormDataModel::fromJson($contactFormToDelete);
                $deleteContactFormRequestDataModel->contactFormToDelete = $contactFormDataModel;
            }
        }

        return $deleteContactFormRequestDataModel;
    }

}