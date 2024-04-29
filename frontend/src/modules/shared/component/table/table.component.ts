import { Component, Input, OnChanges, OnInit } from "@angular/core";
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

  constructor() {}
  // TODO: Guess table size
  // TODO: Paginator

  ngOnChanges(changes: AngularCustomTypes.ImprovedChanges<SharedTableComponent<T>>): void {
    if (changes.columns) this.updateDisplayColumns(changes.columns.currentValue);
  }

  ngOnInit() {}

  /** Updates the string display column name array */
  updateDisplayColumns(columns = this.columns) {
    this.displayColumns = columns.map((x) => x.propertyName);
  }
}
