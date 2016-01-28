package main

import (
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/kr/pretty"
)

func TestHello(t *testing.T) {
	cases := []struct {
		request         *http.Request
		wantStatus      int
		wantContentType string
		wantBody        string
	}{
		{
			request:         httptest.NewRequest("GET", "localhost:8001", nil),
			wantStatus:      200,
			wantContentType: "text/plain; charset=UTF-8",
			wantBody:        "hello world",
		},
	}

	for _, c := range cases {
		rw := httptest.NewRecorder()
		helloHandler(rw, c.request)

		resp := rw.Result()
		if resp.StatusCode != c.wantStatus {
			t.Errorf(
				"helloHandler()\ngot status:  %d\nwant status: %d\n\nrequest:\n%s",
				resp.StatusCode,
				c.wantStatus,
				pretty.Sprint(c.request),
			)
			continue
		}

		if ctype := resp.Header.Get("Content-Type"); !strings.EqualFold(ctype, c.wantContentType) {
			t.Errorf(
				"helloHandler()\ngot content-type:  %s\nwant content-type: %s\n\nrequest:\n%s",
				ctype,
				c.wantContentType,
				pretty.Sprint(c.request),
			)
			continue
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			t.Errorf(
				"helloHandler()\nunexpected error while reading response body: %v\n\nrequest:\n%s\n\nresponse:\n%s",
				err,
				pretty.Sprint(c.request),
				pretty.Sprint(resp),
			)
			continue
		}

		if string(body) != c.wantBody {
			t.Errorf(
				"helloHandler()\nunexpected response body\ngot:  %s\nwant: %s\n\nrequest:\n%s\n\nresponse:\n%s",
				body,
				c.wantBody,
				pretty.Sprint(c.request),
				pretty.Sprint(resp),
			)
		}
	}
}
