import snakeCase from 'snake-case-typescript';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
// @ts-ignore
import Rails from '@rails/ujs';
import { HttpVerb } from './http_verb';

class UrlParameterPath {
  path: string[];

  constructor(readonly root: string, path?: string[]) {
    this.path = path || [];
  }

  withSegment(segment: string) {
    const extendedPath: string[] = Object.assign([], this.path);
    extendedPath.push(segment);
    return new UrlParameterPath(this.root, extendedPath);
  }

  key() {
    return snakeCase(this.root) + this.path.map(s => `[${snakeCase(s)}]`).join('');
  }

  serializeWithValue(value: any) {
    return `${encodeURIComponent(this.key())}=${encodeURIComponent(value)}`;
  }
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  ajax<X>(type: HttpVerb, url: string, data: object): Observable<X> {
    console.log('ajax', url);
    return new Observable<X>((observer) => {
      let subscribed = true;
      const params = this.serializeUrlParams(data);
      console.log('params', params);
      Rails.ajax({
	type,
	url,
	dataType: 'json',
	data: params,
	success: (response: X) => { if (subscribed) { observer.next(response); } },
	error: (response: any) => { if (subscribed) { observer.error(response); } }
      });
      return {
	unsubscribe() {
	  subscribed = false;
	}
      };
    });
  }

  private serializeUrlParams(data: object) {
    const partsAccumulator: string[] = [];
    for (let [key, value] of Object.entries(data)) {
      this.serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
    }
    return partsAccumulator.join('&');
  }

  private serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
    if (typeof value === "object") {
      for (let [key, subValue] of Object.entries(value)) {
	this.serializeUrlParamsPart(subValue, path.withSegment(key), partsAccumulator);
      }
    } else {
      partsAccumulator.push(path.serializeWithValue(value));
    }
  }
}
