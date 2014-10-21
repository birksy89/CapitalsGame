<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="View.ascx.cs" Inherits="Christoc.Modules.CapitalsGame.View" %>


<div class="container-fluid">

    <div class="row">

        <div class="col-xs-3">
            <h3 class="text-center">Lives Remaining</h3>
            <h1 id="txtCurrentLives" runat="server" class="text-center"></h1>
        </div>

        <div class="col-xs-6">
            <h1 class="text-center">What is the capital of <span id="txtCountry" runat="server"></span>?</h1>

            <!--This stores the answer, it is used to create the map pin -->
            <asp:HiddenField ID="txtCapital" runat="server" />

            <asp:RadioButtonList ID="rblAnswers" runat="server" CssClass="radio text-center" RepeatLayout="Flow" RepeatDirection="Horizontal"></asp:RadioButtonList>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit " OnClick="btnSubmit_Click" CssClass="btn btn-success btn-lg btn-block" />

        </div>

        <div class="col-xs-3">
            <h3 class="text-center">Current Score</h3>
            <h1 id="txtCurrentScore" runat="server" class="text-center"></h1>
        </div>

    </div>

    <br />
    <div class="row">

        <div class="col-xs-12">

            
            <div id="Output" runat="server" class="" role="alert"></div>

        </div>
    </div>


    <hr />



    <div class="row">

        <div class="col-xs-12">

            <h2 class="text-center">Bonus Point - Locate the City...</h2>
            <p class="text-center">Move the pin to where you think the city is. The closer you are, the more points you will be awarded</p>

            <div id="map-canvas"></div>

            <input type="button" value="I think it's in the right place..." onclick="codeAddress()" class="btn btn-primary btn-lg btn-block">



            <input id="txtDistanceScore" type="hidden" runat="server" value="0" />


        </div>
    </div>

    <br />
    <div class="row">

        <div class="col-xs-12">


            <div class="input-group input-group-lg">
                <div class="input-group-addon">You Placed It:</div>
                <input class="form-control" id="txtDistance" type="text"  readonly="readonly" />
                <div class="input-group-addon">Kms Away</div>
            </div>


        </div>
    </div>

    <hr />

    <div class="row">

        <div class="col-xs-6">
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-danger btn-lg btn-block" OnClick="btnReset_Click" />
        </div>

        <div class="col-xs-6">
            <asp:Button ID="btnNext" runat="server" Text="Next Question" OnClick="btnNext_Click" CssClass="btn btn-success btn-lg btn-block" />
        </div>
    </div>

</div>

<style type="text/css">
    #map-canvas {
        height: 300px;
        margin: 0;
        padding: 0;
    }

        #map-canvas img {
            max-width: none;
        }





    input[type=radio] {
        display: none;
    }

        input[type=radio] + label {
            display: inline-block;
            margin: -2px;
            padding: 4px 12px;
            margin-bottom: 0;
            font-size: 14px;
            line-height: 20px;
            color: #333;
            text-align: center;
            text-shadow: 0 1px 1px rgba(255,255,255,0.75);
            vertical-align: middle;
            cursor: pointer;
            background-color: #f5f5f5;
            background-image: -moz-linear-gradient(top,#fff,#e6e6e6);
            background-image: -webkit-gradient(linear,0 0,0 100%,from(#fff),to(#e6e6e6));
            background-image: -webkit-linear-gradient(top,#fff,#e6e6e6);
            background-image: -o-linear-gradient(top,#fff,#e6e6e6);
            background-image: linear-gradient(to bottom,#fff,#e6e6e6);
            background-repeat: repeat-x;
            border: 1px solid #ccc;
            border-color: #e6e6e6 #e6e6e6 #bfbfbf;
            border-color: rgba(0,0,0,0.1) rgba(0,0,0,0.1) rgba(0,0,0,0.25);
            border-bottom-color: #b3b3b3;
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffffff',endColorstr='#ffe6e6e6',GradientType=0);
            filter: progid:DXImageTransform.Microsoft.gradient(enabled=false);
            -webkit-box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
            -moz-box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.2),0 1px 2px rgba(0,0,0,0.05);
        }

        input[type=radio]:checked + label {
            background-image: none;
            outline: 0;
            -webkit-box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
            -moz-box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
            box-shadow: inset 0 2px 4px rgba(0,0,0,0.15),0 1px 2px rgba(0,0,0,0.05);
            background-color: #e0e0e0;
        }


    input#txtDistance {
        text-align: center;
    }
</style>


<script type="text/javascript"
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBwU7veszRzr10PJvi2Bapbu-dCKPqHcgU&libraries=geometry">
</script>


<script type="text/javascript">

    var geocoder;
    var map;

    var p1;
    var p2;

    //var p1 = new google.maps.LatLng(51.5073509, -0.1277583); //London
    //var p2 = new google.maps.LatLng(54.5311948, -1.5533484); //Darlington

    // Styles
    var mapStyle = [{ "stylers": [{ "visibility": "off" }] }, { "featureType": "landscape", "elementType": "geometry", "stylers": [{ "visibility": "on" }, { "saturation": 0 }, { "lightness": 0 }] }, { "featureType": "water", "stylers": [{ "visibility": "on" }, { "lightness": 0 }, { "saturation": 0 }] }, { "featureType": "administrative.province", "elementType": "geometry", "stylers": [{ "visibility": "on" }] }, { "featureType": "administrative.country", "elementType": "geometry", "stylers": [{ "visibility": "on" }] }, { "featureType": "water", "elementType": "labels", "stylers": [{ "visibility": "off" }] }, { "featureType": "road.local", "elementType": "geometry.fill", "stylers": [{ "visibility": "on" }, { "color": "#000000" }, { "lightness": 90 }] }];
    //End Style

    function initialize() {
        geocoder = new google.maps.Geocoder();
        var latlng = new google.maps.LatLng(25, 0);
        var mapOptions = {
            zoom: 2,
            center: latlng,
            styles: mapStyle

        }



        map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);


        // Place a draggable marker on the map
        var marker = new google.maps.Marker({
            position: latlng,
            map: map,
            draggable: true,
            //animation: google.maps.Animation.BOUNCE,
            title: "Drag me!"
        });

        p2 = latlng;

        google.maps.event.addListener(marker, 'dragend', function (event) {
            p2 = new google.maps.LatLng(event.latLng.lat(), event.latLng.lng())
        });
    }

    function codeAddress() {
        var address = document.getElementById('<%= txtCapital.ClientID %>').value;
        geocoder.geocode({ 'address': address }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {

                p1 = results[0].geometry.location;

                //map.setCenter(results[0].geometry.location);

                map.panTo(p1);

                var marker = new google.maps.Marker({
                    map: map,
                    position: results[0].geometry.location,
                    icon: 'http://mt.google.com/vt/icon?psize=30&font=fonts/arialuni_t.ttf&color=ff304C13&name=icons/spotlight/spotlight-waypoint-a.png&ax=43&ay=48&text=%E2%80%A2&scale=1'
                });

                calcDistance();

            } else {
                alert('Geocode was not successful for the following reason: ' + status);
            }
        });
    }

    google.maps.event.addDomListener(window, 'load', initialize);

    /////////////////////////////
    function calcDistance() {

        //alert(calcDistance(p1, p2) + " KMs");

        document.getElementById('txtDistance').value = calcDistance(p1, p2);

        //calculates distance between two points in km's
        function calcDistance(p1, p2) {
            return (google.maps.geometry.spherical.computeDistanceBetween(p1, p2) / 1000).toFixed(2);
        }


        //Gives points based on distance away from target

        var earthRadius = 6378137 / 1000;

        var userDistance = calcDistance(p1, p2);

        var distanceScore = (earthRadius - userDistance) / 100 + 120;

        document.getElementById('<%= txtDistanceScore.ClientID %>').value = distanceScore;

    }

    ////////////








</script>



