import { Component, ElementRef, Input, OnChanges, OnInit } from "@angular/core";
import { PageEvent } from "@angular/material/paginator";
import { Base, CustomTypes } from "@common";
import { AngularCustomTypes } from "@frontend/modules/shared/types/angular.types";
import { startCase } from "lodash";

/** Defines a column that will be displayed by this table with some metadata */
export class Column<T extends Base> {
  constructor(
    public propertyName: CustomTypes.PropertyNames<T, any>,
    /** Used to change how the value is actually displayed within the table */
    public renderOverride?: { (val: T): string },
    /** What to display the property name as. Normally just a cleaned up version */
    public displayName = startCase(propertyName),
  ) {}
}

@Component({
  selector: "shared-table[data][columns]",
  templateUrl: "./table.component.html",
  styleUrls: ["./table.component.scss"],
})
export class SharedTableComponent<T extends Base> implements OnInit, OnChanges {
  /** The header columns we want to display in this table */
  @Input() columns!: Column<T>[];
  /** Parsed from columns to only contain strings */
  displayColumns: string[] = [];
  /** The data we would like to display */
  @Input() data!: T[];

  /// Pagination
  /** How many rows that should be displayed per page */
  @Input() pageSize: number = 10;
  @Input() pageSizeOptions = [this.pageSize, 25, 100];
  /** If pagination should be supported */
  @Input() paginate = true;
  currentPage = 0;
  /** The data to be displayed based on pagination. */
  currentPageData: T[] = [];
  /** If set to true, we'll try and guess the pagination size based on the size of the parent container. */
  @Input() shouldGuessPageSize = true;
  private rowHeight = 52;
  private headerHeight = 56;
  private paginatorHeight = 58;
  private searchContainerHeight = 90;

  /// Search
  @Input() shouldAllowSearch = true;
  /** What we are searching for */
  searchTerm = "";
  /** What column we are searching on */
  searchOption: Column<T> | undefined;

  constructor(private ref: ElementRef<HTMLElement>) {}

  ngOnChanges(changes: AngularCustomTypes.ImprovedChanges<SharedTableComponent<T>>): void {
    if (changes.columns) this.updateDisplayColumns(changes.columns.currentValue);
    this.updatePagedData();
  }

  /** Guesses how many rows we can fit in our current div and updates the page size option */
  private get guessedPageSize() {
    if (!this.shouldGuessPageSize) return this.pageSize;
    const totalHeight = this.ref.nativeElement.clientHeight - this.searchContainerHeight - this.headerHeight - this.paginatorHeight;
    return Math.floor(totalHeight / this.rowHeight);
  }

  /** Returns the data to display based on pagination status */
  private getPagedData(data = this.data) {
    if (!this.paginate) return data;
    return data.slice(this.currentPage * this.pageSize, (this.currentPage + 1) * this.pageSize);
  }

  /** Updates the paged data with the filtered content */
  filterData(searchOption = this.searchOption, searchTerm = this.searchTerm) {
    if (!this.shouldAllowSearch || searchOption == null || !searchTerm) return this.data;
    return this.data.filter((x) => JSON.stringify(x[searchOption!.propertyName]).includes(searchTerm));
  }

  /** Updates our display data based on pagination config */
  updatePagedData() {
    const filterData = this.filterData();
    this.currentPageData = this.getPagedData(filterData);
  }

  /** Handles when the paginator content changes from the user */
  handlePaginatorUpdate(event: PageEvent) {
    this.currentPage = event.pageIndex;
    this.pageSize = event.pageSize;
    this.updatePagedData();
  }

  ngOnInit() {
    this.updatePagedData();
    if (this.shouldGuessPageSize) {
      const guessedSize = this.guessedPageSize;
      this.pageSize = guessedSize;
      this.pageSizeOptions.push(guessedSize);
      this.pageSizeOptions = this.pageSizeOptions.sort((a, b) => a - b);
    }
    this.searchOption = this.columns[0];
  }

  /** Updates the string display column name array */
  updateDisplayColumns(columns = this.columns) {
    this.displayColumns = columns.map((x) => x.propertyName);
  }
}
