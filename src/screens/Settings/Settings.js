import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Image,
  TextInput,
  FlatList,
} from "react-native";
import React, { useEffect, useState, useRef } from "react";
import { useNavigation } from "@react-navigation/native";

import { myColors } from "../../../colors";
import { FontAwesome, Feather } from "@expo/vector-icons";
import { FontAwesome5 } from "@expo/vector-icons";

import { auth } from "../../../firebase";
import { signOut } from "firebase/auth";

import { supabase } from "../../initSupabase";

import { getUserByID } from "../../../supabaseQueries";

const Settings = () => {
  const [user, setUser] = useState(null);
  const [name, setName] = useState(null);
  const [status, setStatus] = useState(null);
  const [image, setImage] = useState(null);
  const [selecting, setSelecting] = useState(false);

  const navigation = useNavigation();
  const [editable, setEditable] = useState(false);
  const refInputName = useRef(null);
  const onSignOutPressed = () => {
    // Auth.signOut();
    signOut(auth);
  };

  const fetchUser = async () => {
    const userInfo = auth.currentUser;
    const userData = await getUserByID(userInfo.uid);

    // const userInfo = await Auth.currentAuthenticatedUser();
    // const userData = await API.graphql(
    //   graphqlOperation(getUser, { id: userInfo.attributes.sub })
    // );
    // console.log(userData.data.getUser);
    setUser(userData);
    setName(userData.name);
    setImage(userData.image);
    setStatus(userData.status);
  };
  useEffect(() => {
    fetchUser();
  }, []);

  useEffect(() => {
    navigation.setOptions({
      headerTitle: "Settings",
      headerTintColor: "white",
      headerStyle: {
        backgroundColor: myColors.pbgc,
        color: "white",
      },
      headerBackTitle: "Back",
      headerRight: () => (
        <>
          <Text
            style={{
              color: "white",
              fontSize: 20,
              fontWeight: "bold",
            }}
            onPress={onSignOutPressed}>
            Sign Out
          </Text>
        </>
      ),
    });
  }, []);

  const handelImageChange = async (item) => {
    console.log("image changed");
    // refInputName.current?.blur();
    const { data, error } = await supabase
      .from("User")
      .update({
        image: `https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/${item}.jpg`,
      })
      .eq("id", user.id)
      .select();

    console.log(data, error);
    fetchUser();
  };

  const handelStatusChange = async () => {
    if (status.length < 3) {
      alert("Status must be atleast 3 characters long");
      setStatus(user.status);
      return;
    }
    await supabase.from("User").update({ status: status }).eq("id", user.id);
    fetchUser();
  };

  const handelNameChange = async () => {
    if (name.length < 3) {
      alert("Name must be atleast 3 characters long");
      setName(user.name);
      return;
    }
    await supabase.from("User").update({ name: name }).eq("id", user.id);
    fetchUser();
  };

  return (
    <View style={styles.root}>
      {selecting ? (
        <View
          style={{
            marginTop: 10,
            height: "50%",
            marginBottom: 10,
            // backgroundColor: "white",
            // width: "100%",
          }}>
          <FlatList
            // horizontal={true}
            // style={{ width: "100%", height: 100 }}
            data={["1", "2", "3", "4"]}
            renderItem={({ item }) => (
              <Pressable
                onPress={() => {
                  setSelecting(false);
                  setImage(
                    `https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/${item}.jpg`
                  );
                  handelImageChange(item);
                }}
                style={{
                  // backgroundColor: "red",
                  padding: 10,
                  // justifyContent: "center",
                  // alignItems: "center",
                  height: "80%",
                  // marginVertical: 10,
                }}>
                <Image
                  source={{
                    uri: `https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/${item}.jpg`,
                  }}
                  style={{
                    borderRadius: 100,
                    width: 150,
                    height: 150,
                  }}
                  // resizeMode="cover"
                />
              </Pressable>
            )}
            numColumns={2}
            columnWrapperStyle={{ justifyContent: "space-around" }}
          />
        </View>
      ) : (
        <Pressable
          style={styles.imageContainer}
          onPress={() => setSelecting(true)}>
          <Image source={{ uri: image }} style={styles.image} />
        </Pressable>
      )}

      <Pressable
        style={({ pressed }) =>
          pressed ? styles.containerPressed : styles.container
        }
        onPress={() => refInputName.current?.focus()}>
        <FontAwesome
          style={styles.icon1}
          name="user"
          size={24}
          color={myColors.secondaryText}
        />
        <View style={styles.content}>
          <Text style={styles.title}>Name</Text>
          <TextInput
            style={styles.subTitle}
            ref={refInputName}
            maxLength={20}
            onChangeText={(text) => setName(text)}
            onSubmitEditing={handelNameChange}
            value={name}
          />
          <Text
            style={{
              color: myColors.secondaryText,
              marginTop: 10,
              fontSize: 12,
            }}>
            This is not your username or pin. This name will be visible to your
            chat contacts.
          </Text>
        </View>
        <FontAwesome5
          style={styles.icon2}
          name="pen"
          size={18}
          color={myColors.secondaryText}
        />
      </Pressable>
      <Pressable
        style={({ pressed }) =>
          pressed ? styles.containerPressed : styles.container
        }>
        <Feather
          style={styles.icon1}
          name="info"
          size={24}
          color={myColors.secondaryText}
        />
        <View style={styles.content}>
          <Text style={styles.title}>About</Text>
          <TextInput
            style={styles.subTitle}
            maxLength={30}
            onChangeText={(text) => setStatus(text)}
            onSubmitEditing={handelStatusChange}
            value={status}
          />
        </View>
        <FontAwesome5
          style={styles.icon2}
          name="pen"
          size={18}
          color={myColors.secondaryText}
        />
      </Pressable>
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    backgroundColor: myColors.pbgc,
    flex: 1,
  },
  imageContainer: {
    height: 200,
    justifyContent: "center",
    alignItems: "center",
    marginVertical: 10,
  },
  image: {
    borderRadius: 100,
    width: "50%",
    height: "90%",
  },
  container: {
    // backgroundColor: "#1e1e1e",
    flexDirection: "row",
    marginHorizontal: 10,
    marginVertical: 5,
    paddingVertical: 10,
    // marginBottom: 20,
    // height: 130,
  },
  containerPressed: {
    flexDirection: "row",
    marginHorizontal: 10,
    marginVertical: 5,
    paddingVertical: 10,
    // marginBottom: 20,
    // height: 130,
    backgroundColor: "#1e1e1e",
    borderRadius: 10,
  },
  content: {
    flex: 1,
    height: "105%",
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: "grey",
  },
  icon1: {
    width: "14%",
    height: 50,
    // borderRadius: 30,
    marginRight: 10,
    textAlign: "center",
  },
  icon2: {
    // paddingTop: 10,
    width: "14%",
    // height: 50,
    // borderRadius: 30,
    marginRight: 10,
    textAlign: "center",
  },
  row: {
    flexDirection: "row",
    marginBottom: 5,
  },
  name: {
    // fontWeight: "bold",
    fontSize: 16,
    color: myColors.secondaryText,
    flex: 1,
  },
  title: {
    color: myColors.secondaryText,
    fontSize: 14,
  },
  subTitle: {
    fontSize: 16,
    color: "white",
  },
});

export default Settings;
