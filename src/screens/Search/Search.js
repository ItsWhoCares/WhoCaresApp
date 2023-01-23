import { View, Text, FlatList, StyleSheet, TextInput } from "react-native";
import React, { useEffect, useLayoutEffect } from "react";
import SearchListItem from "../../components/SearchListItem";
import { myColors } from "../../../colors";
import { useNavigation } from "@react-navigation/native";
import { AntDesign } from "@expo/vector-icons";
import ChatInput from "../../components/ChatInput";

import { listUsers } from "../../../supabaseQueries";

const Search = () => {
  const navigation = useNavigation();
  const [SearchText, setSearchText] = React.useState("");

  const [users, setUsers] = React.useState([]);
  const [loading, setLoading] = React.useState(false);
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const users = await listUsers();
      setUsers(users);
    } catch (e) {
      console.log(e);
    } finally {
      setLoading(false);
    }
  };
  const querySearchText = (text) => {
    console.log(text);
    if (text.length === 0) {
      fetchUsers();
      return;
    }
    // setSearchText(text);
    //filter users
    const filteredUsers = users.filter((item) => {
      return item.name.toLowerCase().includes(text.toLowerCase());
    });
    console.log(users);
    console.log(JSON.stringify(filteredUsers, null, "\t"));
    setUsers([]);
    setUsers(filteredUsers);
  };

  //might need to use useLayoutEffect
  useLayoutEffect(() => {
    navigation.setOptions({
      headerShown: true,
      headerTitle: "",
      headerStyle: {
        backgroundColor: myColors.pbgc,
      },
      headerLeft: () => (
        <>
          <AntDesign
            onPress={navigation.goBack}
            name="arrowleft"
            size={24}
            color="white"
          />
          <View style={styles.inputContainer}>
            <TextInput
              // autoFocus={true}
              // value={SearchText}
              onChangeText={(text) => querySearchText(text)}
              placeholder="Search..."
              placeholderTextColor={"gray"}
              style={styles.input}
            />
          </View>
        </>
      ),
    });
  }, [users]);

  useEffect(() => {
    fetchUsers();
    console.log("fetching users");
  }, []);

  return (
    <View style={styles.root}>
      <FlatList
        data={users}
        renderItem={({ item }) => <SearchListItem user={item} />}
        onRefresh={fetchUsers}
        refreshing={loading}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: myColors.pbgc,
    paddingVertical: 10,

    justifyContent: "center",
    // alignItems: "center",
  },
  inputContainer: {
    flex: 1,
    // alignItems: "center",
    // flexDirection: "row",
    // // backgroundColor: myColors.SecondaryMessage,
    // // borderRadius: 25,
    // // justifyContent: "space-between",
    // // alignItems: "center",
    // // paddingHorizontal: 8,
    // // paddingVertical: 4,
    // // marginHorizontal: 15,
    // // marginVertical: 10,
    // // marginBottom: 10,
  },
  input: {
    // flex: 1,

    height: 40,
    width: "80%",
    backgroundColor: myColors.SecondaryMessage,
    borderColor: myColors.SecondaryMessage,
    borderWidth: 1,
    paddingHorizontal: 20,
    marginLeft: 15,
    // marginRight: 8,
    borderRadius: 20,
    color: "white",
  },
});

export default Search;
