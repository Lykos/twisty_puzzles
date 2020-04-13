import { Component, OnInit } from '@angular/core';
import { ModeService } from './mode.service';
import { Mode } from './mode';
import { Router } from '@angular/router';

@Component({
  selector: 'modes',
  template: `
<div>
  <h2>Modes</h2>
  <div>
    <table mat-table [dataSource]="modes">
      <mat-text-column name="name"></mat-text-column>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let mode; columns: columnsToDisplay" (click)="onClick(mode)"></tr>
    </table>
  </div>
  <div>
    <button mat-raised-button color="primary" (click)="onNew()">
      New
    </button>
  </div>
</div>
`
})
export class ModesComponent implements OnInit {
  modes: Mode[] = [];
  columnsToDisplay = ['name'];

  constructor(private readonly modeService: ModeService,
	      private readonly router: Router) {}

  onClick(mode: Mode) {
    this.router.navigate([`/trainer/${mode.id}`]);
  }

  ngOnInit() {
    this.modeService.list().subscribe((modes: Mode[]) => this.modes = modes);
  }

  onNew() {
    this.router.navigate(['/modes/new']);
  }
}
