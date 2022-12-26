import "react-native-url-polyfill/auto";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "https://kllspqoqajlddmvgnsft.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsbHNwcW9xYWpsZGRtdmduc2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzE0NTc3OTcsImV4cCI6MTk4NzAzMzc5N30.-L9aJ-RjtphZTwzaR02m0JZOB-QsfxVYtm-G0HhavmA";

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export const getMessageByID = async (id) => {
  const { data, error } = await supabase
    .from("Message")
    .select("*")
    .eq("id", id);
  if (error) {
    console.log(error);
  }
  return data[0];
};
