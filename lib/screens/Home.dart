import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget.dart';
class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();

  final String _url = 'http://193.227.0.21/Nctu/Registration/ED_Login.aspx';
  final String _url2 = 'https://nctu.edu.eg/';

  void _launchURL() async {
    final Uri url = Uri.parse(_url);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // <-- Important for browser
    )) {
      throw Exception('Could not launch $_url');
    }
  }
  void _NCTU() async {
    final Uri url = Uri.parse(_url2);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // <-- Important for browser
    )) {
      throw Exception('Could not launch $_url2');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(height: 200,
              child:Stack(
                children: [
                  PageView(
                    controller: _controller,
                    children: [

                      sliderItem(
                        image: 'https://egy-map.com/uploads/projects/photos/1625-photo-16006057535f674e391f7ee.jpg',
                        title: 'Adminstartion is open 2025',
                        subtitle: 'Join us',
                      ),

                      sliderItem(
                        image: 'https://ntalm-masry.com/wp-content/uploads/2024/07/elaosboa23084-2.jpg',
                        title: 'Adminstartion is open 2025',
                        subtitle: 'Join us',
                      ),

                      sliderItem(
                        image: 'https://egy-map.com/uploads/projects/photos/1625-photo-16006057535f674e391f7ee.jpg',
                        title: 'Adminstartion is open 2025',
                        subtitle: 'Join us',
                      ),


                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0 ,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: ScrollingDotsEffect() ,
                      ),
                    ),
                  )
                ],
              ),
                ),

            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2)
                ),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _launchURL();
                    });

                  } ,
                  child: Card(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(Icons.description,color: Colors.white,),
                            backgroundColor: Colors.blueAccent,

                          ),
                        ),
                        SizedBox(width: 16,),
                        Column(
                          children: [
                            Text("student Degrees",style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                            ),
                            SizedBox(height: 4,),
                            Text('2024-2025', style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),)
                          ],
                        )
                      ],
                    )
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2)
                ),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _NCTU();
                    });

                  } ,
                  child: Card(
                    color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(Icons.g_mobiledata,color: Colors.white,),
                              backgroundColor: Colors.blueAccent,

                            ),
                          ),
                          SizedBox(width: 16,),
                          Column(
                            children: [
                              Text("NCTU",style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                              ),
                              SizedBox(height: 4,),
                              Text('more info...', style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),)
                            ],
                          )
                        ],
                      )
                  ),
                ),
              ),
            ),



          ],
        ),
      )
    );

  }


}