
import 'package:birthday_app/database/birthdaysDB.dart';
import 'package:birthday_app/models/person.dart';
import 'package:birthday_app/screens/screen_add_person.dart';
import 'package:birthday_app/utils/enums.dart';
import 'package:birthday_app/utils/helpers/save_person_controller.dart';
import 'package:birthday_app/utils/methods.dart';
import 'package:birthday_app/utils/providers.dart';
import 'package:birthday_app/utils/services/local_notif_service.dart';
import 'package:birthday_app/utils/styling.dart';
import 'package:birthday_app/utils/values.dart';
import 'package:birthday_app/widgets/failure_snackbar.dart';
import 'package:birthday_app/widgets/success_snackbar.dart';
import 'package:birthday_app/widgets/vertical_space.dart';
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

  void editPerson() {

    Navigator.of(context).pop();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SaveUserController(
        child: AddPersonScreen(
          screenMode: ScreenMode.update,
          personToEdit: thePerson
        )
      ))
    );
  }

  Future<void> deletePerson() async {

    ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
    NavigatorState navigatorState = Navigator.of(context);
    navigatorState.pop();

    bool res = await BirthdaysDB.instance.deletePersonFromDB(thePerson.personID!);

    if(res){      
      LocalNotifService.instance.cancelScheduledNotification(thePerson.personID!);
      ref.read(personNotifierProvider.notifier).removePersonFromList(thePerson.personID!);
      messengerState..clearSnackBars()..showSnackBar(
        SuccessSnackbar("Kişi silindi")
      );
      navigatorState.pop();
    }
    else{
      messengerState..clearSnackBars()..showSnackBar(
        FailureSnackbar("Bir hata meydana geldi")
      );
    }
  }

  void showOptionsBottomNavSheet() async {

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical( 
          top: Radius.circular(25.0),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.25
      ),
      builder: (context) {
        
        return Column(
          children: [
            VerticalSpace(12),
            ListTile(
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: () => editPerson(),
              leading: const Icon(Icons.edit, color: Colors.black,),
              title: Text(
                "Düzenle", 
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                  fontFamily: TextFonts.nunitoSans.fontName
                ),
              ),
              subtitle: null,
            ),
            ListTile(
              horizontalTitleGap: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: () => deletePerson(),
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red,),
              title: Text(
                "Sil", 
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: TextFonts.nunitoSans.fontName
                ),
              ),
              subtitle: null,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Person> people = ref.watch(personNotifierProvider);
    try{
      thePerson = people.firstWhere((person) => person.personID == widget.person.personID);
    }
    catch(exp){
      return Container();
    }
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: IconButton(
                  onPressed: () {
                    showOptionsBottomNavSheet();
                  },
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              )
            ],
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
                      trailing: Person.isTodayBirthday(thePerson) ? Icon(Icons.cake, color: Colors.yellow.shade700,) : null,
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