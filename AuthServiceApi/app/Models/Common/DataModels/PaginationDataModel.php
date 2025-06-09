<?php

namespace App\Models\Common\DataModels;

use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;

class PaginationDataModel extends BaseDataModel
{
    public $currentPage;
    public $pageSize;
    public $totalRecords;
    public $totalPages;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $paginationDataModel = new self();

        if ($jsonData != null)
        {
            $paginationDataModel->currentPage = $jsonData->currentPage ?? null;
            $paginationDataModel->pageSize = $jsonData->pageSize ?? null;
            $paginationDataModel->totalRecords = $jsonData->totalRecords ?? null;
            $paginationDataModel->totalPages = $jsonData->totalPages ?? null;
        }

        return $paginationDataModel;
    }

    // Create instances from database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $pagination = [];

        if ($dbResultSet != null)
        {
            foreach ($dbResultSet as $row)
            {
                $pagination[] = self::fromDbResultRow($row);
            }
        }

        return $pagination;
    }

    // Create an instance from a single database result row
    public static function fromDbResultRow($row)
    {
        $pagination = null;

        if ($row != null)
        {
            $objRow = is_object($row) ? $row : (object)$row;
            $pagination = new self();
            $pagination->currentPage = $objRow->CurrentPage ?? null;
            $pagination->pageSize = $objRow->PageSize ?? null;
            $pagination->totalRecords = $objRow->TotalRecords ?? null;
            $pagination->totalPages = $objRow->TotalPages ?? null;
        }

        return $pagination;
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }

  
}
?>
