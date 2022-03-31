import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/fonts.dart';
import '../../assets/icos.dart';
import '../../widgets/button/tap_effect.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  var isFocused = false.obs;

  @override
  void initState() {
    _searchFocusNode.addListener(() {
      isFocused.value = _searchFocusNode.hasFocus;
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBarSize = AppBar().preferredSize;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(10),
        )),
        centerTitle: true,
        leading: Obx(
          () => AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: isFocused.value ? 0 : 0.25,
            child: TapEffect(
              onTap: isFocused.value
                  ? () => _searchFocusNode.unfocus()
                  : () => Get.back(),
              child: const Icon(Icos.down_arrow_2),
            ),
          ),
        ),
        title: SizedBox(
          height: appBarSize.height * 0.68,
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              suffixIcon: Icon(
                Icos.search,
                color: Theme.of(context).colorScheme.primary,
                size: 25,
              ),
            ),
            maxLines: 1,
            style: Fonts.itim_16_1dot5,
          ),
        ),
      ),
      body: const Center(
        child: Text('Search Screen'),
      ),
    );
  }
}
