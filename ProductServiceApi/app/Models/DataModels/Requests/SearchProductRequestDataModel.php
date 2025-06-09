<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};

class SearchProductRequestDataModel extends PaginationRequestDataModel
{

    public $product;
    public $brand;
    public $category;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        $product = $this->product;
        $brand = $this->brand;
        $category = $this->category;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                empty($product)
            ) &&
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'product, currentPage, pageSize, businessProfileId');
        }

        // Optional inputs and setting defaults
        // Add additional defaults here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchProductRequestDataModel = new SearchProductRequestDataModel();

        if ($jsonData !== null) {

            $product = $jsonData->product ?? null;
            if ($product !== null) {
                $searchProductRequestDataModel->product = ProductDataModel::fromJson($product);
            }

            $brand = $jsonData->brand ?? null;
            if ($brand !== null) {
                $searchProductRequestDataModel->brand = BrandDataModel::fromJson($brand);
            }

              $category = $jsonData->category ?? null;
            if ($category !== null) {
                $searchProductRequestDataModel->category = CategoryDataModel::fromJson($category);
            }

            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $searchProductRequestDataModel->pagination = PaginationDataModel::fromJson($pagination);
            }
        }

        return $searchProductRequestDataModel;
    }
}