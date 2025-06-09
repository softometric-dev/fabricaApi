<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Libraries\{ParameterException};

class SearchBrandRequestDataModel extends PaginationRequestDataModel
{

    public $brand;
    public $category;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $brand = $this->brand;
        $category = $this->category;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($brand)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'brand, currentPage, pageSize');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchBrandRequestDataModel = new SearchBrandRequestDataModel();

        if ($jsonData !== null) {

            $brand = $jsonData->brand ?? null;
            if ($brand !== null) {
                $searchBrandRequestDataModel->brand = BrandDataModel::fromJson($brand);
            }

            $category = $jsonData->category ?? null;
            if ($category !== null) {
                $searchBrandRequestDataModel->category = CategoryDataModel::fromJson($category);
            }


            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchBrandRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchBrandRequestDataModel;
    }
}