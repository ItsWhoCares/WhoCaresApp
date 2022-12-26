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
  const querySearchText = (text) => {
    setSearchText(text);
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
              value={SearchText}
              onChangeText={(text) => querySearchText(text)}
              placeholder="Search..."
              placeholderTextColor={"gray"}
              style={styles.input}
            />
          </View>
        </>
      ),
    });
  }, [SearchText]);

  const [users, setUsers] = React.useState([]);
  const [loading, setLoading] = React.useState(false);
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const users = await listUsers();
      setUsers(users);
      // API.graphql(graphqlOperation(listUsers)).then((res) => {
      //   setUsers(res.data.listUsers.items);
      // });
      // console.log(users);
    } catch (e) {
      console.log(e);
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    fetchUsers();
    //list all users
    // const fetchUsers = async () => {
    //   try {
    //     const usersData = await API.graphql(graphqlOperation(listUsers));
    //     setUsers(usersData?.data?.searchUsers?.items);
    //     console.log(users);
    //   } catch (e) {
    //     console.log(e);
    //   }
    // };
    // fetchUsers();
  }, [SearchText]);

  //log all users
  // useEffect(() => {
  //   API.graphql(graphqlOperation(listUsers)).then((res) => {
  //     console.log(res.data.listUsers.items);
  //   });
  // }, []);

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
