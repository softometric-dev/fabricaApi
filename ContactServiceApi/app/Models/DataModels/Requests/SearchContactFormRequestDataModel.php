<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;
use App\Libraries\{ParameterException};

class SearchContactFormRequestDataModel extends PaginationRequestDataModel
{

    public $contactForm;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $contactForm = $this->contactForm;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($contactForm)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'contactForm, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchContactFormRequestDataModel = new SearchContactFormRequestDataModel();

        if ($jsonData !== null) {

            $contactForm = $jsonData->contactForm ?? null;
            if ($contactForm !== null) {
                $searchContactFormRequestDataModel->contactForm = ContactFormDataModel::fromJson($contactForm);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchContactFormRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchContactFormRequestDataModel;
    }
}