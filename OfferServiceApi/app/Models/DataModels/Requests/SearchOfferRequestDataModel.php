<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use App\Libraries\{ParameterException};

class SearchOfferRequestDataModel extends PaginationRequestDataModel
{

    public $offer;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $offer = $this->offer;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($offer)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'offer, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchOfferRequestDataModel = new SearchOfferRequestDataModel();

        if ($jsonData !== null) {

            $offer = $jsonData->offer ?? null;
            if ($offer !== null) {
                $searchOfferRequestDataModel->offer = OfferDataModel::fromJson($offer);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchOfferRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchOfferRequestDataModel;
    }
}