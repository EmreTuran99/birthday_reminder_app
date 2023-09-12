
import 'package:birthday_app/models/person.dart';
import 'package:birthday_app/utils/enums.dart';
import 'package:birthday_app/utils/methods.dart';
import 'package:birthday_app/utils/providers.dart';
import 'package:birthday_app/utils/styling.dart';
import 'package:birthday_app/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonOverviewScreen extends ConsumerStatefulWidget {

  Person person;
  PersonOverviewScreen(this.person, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonOverviewScreenState();
}

class _PersonOverviewScreenState extends ConsumerState<PersonOverviewScreen> {

  late Size screenSize;
  List<Color> femaleColors = [femaleColor1, femaleColor2];
  List<Color> maleColors = [maleColor1, maleColor2];
  
  late bool isAvatarMale;
  late Person thePerson;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  Widget DetailBuilder(String titleText, String subtitleText){

    return ListTile(
      title: Text(
        titleText,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.normal,
          fontFamily: TextFonts.nunitoSans.fontName
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: TextFonts.nunitoSans.fontName
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Person> people = ref.watch(personNotifierProvider);
    thePerson = people.firstWhere((person) => person.personID == widget.person.personID);
    isAvatarMale = thePerson.avatarPath.compareTo(maleAvatarPath) == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: true,
            expandedHeight: screenSize.height * 0.25,
            leadingWidth: 64,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAvatarMale ? femaleColors : maleColors // reversed on purpose
                  )
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(256),
                    child: Image.asset(
                      widget.person.avatarPath,
                      height: screenSize.height * 0.1,
                      width: screenSize.height * 0.1,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        thePerson.fullname,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: TextFonts.nunitoSans.fontName
                        ),
                      ),
                      subtitle: Text(
                        getBirthDayInfoText(thePerson),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.normal,
                          fontFamily: TextFonts.nunitoSans.fontName
                        ),
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                DetailBuilder("Doğum Tarihi", getDateWithDay(thePerson.birthDate)),
                DetailBuilder("Burç", "${thePerson.zodiacSign.turName} (${thePerson.zodiacSign.engName})"),
                if(thePerson.notes != null)
                  DetailBuilder("Notlar", thePerson.notes!)
              ],
            )
          ),
        ],
      ),  
    );
  }
}