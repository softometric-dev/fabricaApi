<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\CategoryDataModel;

class GetAllCategoriesResponseDataModel extends PaginationResponseDataModel
{
 public $categories;
    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }
    public function validateAndEnrichData()
    {
        // Validation and enrichment logic can be added here.
    }

     public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getAllCategoriesResponseDataModel = new GetAllCategoriesResponseDataModel();

        if ($jsonData !== null) {
            $categories = $jsonData->categories ?? null;
            if ($categories !== null) {
                $getAllCategoriesResponseDataModel->categories = [];
                foreach ($categories as $category) {
                    $categoryDataModel = CategoryDataModel::fromJson(json_encode($category));
                    $getAllCategoriesResponseDataModel->categories[] = $categoryDataModel;
                }
            }

            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $paginationDataModel = PaginationDataModel::fromJson(json_encode($pagination));
                $getAllCategoriesResponseDataModel->pagination = $paginationDataModel;
            }
        }

        return $getAllCategoriesResponseDataModel;
    }
}